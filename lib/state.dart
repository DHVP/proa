import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'data.dart';
import 'reminders.dart';

// ponytail: modo demo solo para probar pantallas sin Firebase (flutter run --dart-define=DEMO=true), guarda en memoria
const demo = bool.fromEnvironment('DEMO');

final navKey = GlobalKey<NavigatorState>();
final messengerKey = GlobalKey<ScaffoldMessengerState>();
final app = AppState();

DateTime today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

String dayKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime weekStart(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));

void toast(String text) {
  messengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

class Profile {
  String name, sex, activity, goal;
  int age;
  bool googlePhoto;
  // ponytail: foto propia en el mismo documento, comprimida a 400 px (unos 40 KB), Storage exige plan de pago
  Uint8List? photo;
  DateTime since;
  Profile({
    required this.name,
    required this.age,
    required this.sex,
    required this.activity,
    required this.goal,
    this.googlePhoto = true,
    this.photo,
    DateTime? since,
  }) : since = since ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'sex': sex,
    'activity': activity,
    'goal': goal,
    'googlePhoto': googlePhoto,
    'photo': photo == null ? null : base64Encode(photo!),
    'since': since.toIso8601String(),
  };

  static Profile fromJson(Map j) => Profile(
    name: j['name'] ?? '',
    age: j['age'] ?? 18,
    sex: j['sex'] ?? 'N',
    activity: j['activity'] ?? 'sedentario',
    goal: j['goal'] ?? 'alimentacion',
    googlePhoto: j['googlePhoto'] ?? true,
    photo: j['photo'] is String ? base64Decode(j['photo']) : null,
    since: DateTime.tryParse(j['since'] ?? ''),
  );
}

class Craving {
  final String emotion;
  final List<String> tried;
  final DateTime at;
  Craving(this.emotion, this.tried, this.at);
  Map<String, dynamic> toJson() => {'emotion': emotion, 'tried': tried, 'at': at.toIso8601String()};
  static Craving fromJson(Map j) => Craving(j['emotion'], List<String>.from(j['tried'] ?? []), DateTime.parse(j['at']));
}

class Account {
  final String uid;
  final String? email, name, photo;
  const Account(this.uid, this.email, this.name, this.photo);
}

enum Phase { loading, signedOut, onboarding, ready, error }

class AppState extends ChangeNotifier {
  Phase phase = Phase.loading;
  Account? account;
  Profile? profile;
  List<int>? answers;
  DateTime? testDate;
  List<String> plan = [];
  Map<String, Map<String, int>> logs = {};
  List<Craving> cravings = [];
  Set<String> saved = {};
  bool remindersOn = false;
  List<Reminder> reminders = defaultReminders();
  int tab = 0;
  Timer? _debounce;

  DocumentReference<Map<String, dynamic>> get _doc => FirebaseFirestore.instance.collection('users').doc(account!.uid);

  Future<void> start() async {
    if (demo) return _onAuth(null);
    await GoogleSignIn.instance.initialize();
    FirebaseAuth.instance.authStateChanges().listen(_onAuth);
  }

  Future<void> _onAuth(User? u, [Account? fake]) async {
    account = fake ?? (u == null ? null : Account(u.uid, u.email, u.displayName, u.photoURL));
    navKey.currentState?.popUntil((r) => r.isFirst);
    if (account == null) {
      _reset();
      phase = Phase.signedOut;
      notifyListeners();
      return;
    }
    await reload();
  }

  Future<void> reload() async {
    phase = Phase.loading;
    notifyListeners();
    try {
      final data = demo ? <String, dynamic>{} : (await _doc.get()).data();
      _reset();
      _load(data ?? {});
      phase = profile != null && answers != null ? Phase.ready : Phase.onboarding;
      tab = 0;
      unawaited(scheduleReminders(remindersOn, reminders));
    } catch (_) {
      phase = Phase.error;
    }
    notifyListeners();
  }

  void _reset() {
    profile = null;
    answers = null;
    testDate = null;
    plan = [];
    logs = {};
    cravings = [];
    saved = {};
    remindersOn = false;
    reminders = defaultReminders();
  }

  void _load(Map<String, dynamic> j) {
    if (j['profile'] is Map) profile = Profile.fromJson(j['profile']);
    if (j['answers'] is List) answers = List<int>.from(j['answers']);
    testDate = DateTime.tryParse(j['testDate'] ?? '');
    plan = List<String>.from(j['plan'] ?? []);
    (j['logs'] as Map? ?? {}).forEach((day, m) => logs[day] = Map<String, int>.from(m));
    cravings = [for (final c in j['cravings'] ?? []) Craving.fromJson(c)];
    saved = Set<String>.from(j['saved'] ?? []);
    remindersOn = j['remindersOn'] ?? false;
    for (final r in reminders) {
      r.load((j['reminders'] as Map?)?[r.id]);
    }
  }

  Map<String, dynamic> _json() => {
    'profile': profile?.toJson(),
    'answers': answers,
    'testDate': testDate?.toIso8601String(),
    'plan': plan,
    'logs': logs,
    'cravings': [for (final c in cravings) c.toJson()],
    'saved': saved.toList(),
    'remindersOn': remindersOn,
    'reminders': {for (final r in reminders) r.id: r.toJson()},
    'email': account?.email,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Cambia el estado, guarda en la nube (Firestore guarda primero en el teléfono si no hay internet)
  void change(VoidCallback fn) {
    fn();
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!demo && account != null) {
        _doc.set(_json()).catchError((Object _) => toast('No pudimos guardar tus cambios, intenta de nuevo'));
      }
    });
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  // ---------- Cuenta ----------

  Future<void> signInWithGoogle() async {
    if (demo) return _onAuth(null, const Account('demo', 'diego@ejemplo.com', 'Diego Vargas', null));
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      await FirebaseAuth.instance.signInWithCredential(GoogleAuthProvider.credential(idToken: token));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled || e.code == GoogleSignInExceptionCode.interrupted) return;
      toast('No pudimos conectar con Google, intenta de nuevo');
    } on FirebaseAuthException catch (e) {
      toast(
        e.code == 'network-request-failed'
            ? 'Sin conexión, revisa tu internet e intenta de nuevo'
            : 'No pudimos iniciar sesión, intenta de nuevo',
      );
    }
  }

  Future<void> signOut() async {
    _debounce?.cancel();
    if (demo) return _onAuth(null);
    if (account != null) await _doc.set(_json());
    await scheduleReminders(false, reminders);
    await GoogleSignIn.instance.signOut().catchError((_) {});
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteAll() async {
    _debounce?.cancel();
    if (demo) return _onAuth(null);
    await _doc.delete();
    await scheduleReminders(false, reminders);
    await GoogleSignIn.instance.disconnect().catchError((_) {});
    await FirebaseAuth.instance.signOut();
  }

  String get firstName => (profile?.name ?? account?.name ?? '').trim().split(' ').first;

  /// Foto propia, si no la de Google, si no ninguna (se ve la inicial)
  ImageProvider? get avatar {
    final p = profile;
    if (p?.photo != null) return MemoryImage(p!.photo!);
    if ((p?.googlePhoto ?? true) && account?.photo != null) return NetworkImage(account!.photo!);
    return null;
  }

  // ---------- Onboarding y test ----------

  void saveProfile(Profile p) => change(() => profile = p);

  /// Guarda el test y arma el plan con los hábitos que más lo necesitan
  void saveTest(List<int> a) => change(() {
    answers = List.of(a);
    testDate = DateTime.now();
    plan = personalPlan(a, profile?.goal ?? 'alimentacion');
    phase = Phase.ready;
  });

  // ---------- Hábitos ----------

  int target(String id) => targetFor(id, profile?.activity ?? 'moderado', answers);
  String goal(String id) => goalFor(id, target(id), profile?.activity ?? 'moderado');
  String time(HabitDef h) => timeFor(h, profile?.activity ?? 'moderado');

  int raw(String id, DateTime d) => logs[dayKey(d)]?[id] ?? 0;

  /// Para comidas el valor es una máscara de bits (desayuno, almuerzo, cena)
  int count(String id, DateTime d) {
    final v = raw(id, d);
    return habitById(id).kind == Kind.meals ? [1, 2, 4].where((b) => v & b != 0).length : v;
  }

  bool done(String id, DateTime d) => count(id, d) >= target(id);

  void setRaw(String id, DateTime d, int v) => change(() {
    final day = logs.putIfAbsent(dayKey(d), () => {});
    if (v <= 0) {
      day.remove(id);
    } else {
      day[id] = v;
    }
  });

  void setDone(String id, DateTime d, bool value) {
    final h = habitById(id);
    setRaw(id, d, !value ? 0 : (h.kind == Kind.meals ? 7 : target(id)));
  }

  int doneCount(DateTime d) => plan.where((id) => done(id, d)).length;

  bool activeDay(DateTime d) => plan.any((id) => done(id, d));

  int streak([String? id]) {
    bool ok(DateTime d) => id == null ? activeDay(d) : done(id, d);
    var d = today();
    if (!ok(d)) d = d.subtract(const Duration(days: 1));
    var n = 0;
    while (ok(d)) {
      n++;
      d = DateTime(d.year, d.month, d.day - 1);
    }
    return n;
  }

  /// Porcentaje de hábitos cumplidos entre dos fechas, sin contar días futuros
  int percent(DateTime from, DateTime to) {
    if (plan.isEmpty) return 0;
    var done = 0, days = 0;
    for (var d = from; !d.isAfter(to) && !d.isAfter(today()); d = DateTime(d.year, d.month, d.day + 1)) {
      done += doneCount(d);
      days++;
    }
    return days == 0 ? 0 : (done * 100 / (days * plan.length)).round();
  }

  void togglePlan(String id) => change(() {
    if (plan.contains(id)) {
      plan.remove(id);
    } else {
      plan = [
        for (final h in habits)
          if (plan.contains(h.id) || h.id == id) h.id,
      ];
    }
  });

  // ---------- Antojos y guías ----------

  void addCraving(String emotion, List<String> tried) =>
      change(() => cravings.insert(0, Craving(emotion, tried, DateTime.now())));

  void toggleSaved(String id) => change(() => saved.contains(id) ? saved.remove(id) : saved.add(id));

  // ---------- Recordatorios ----------

  Future<void> setReminders(bool on) async {
    if (on && !await askNotificationPermission()) {
      toast('Activa las notificaciones de PROA en los ajustes del teléfono');
      return;
    }
    change(() => remindersOn = on);
    await scheduleReminders(remindersOn, reminders);
  }

  Future<void> updateReminder(Reminder r, {bool? on, TimeOfDay? time}) async {
    change(() {
      if (on != null) r.on = on;
      if (time != null) r.time = time;
    });
    await scheduleReminders(remindersOn, reminders);
  }
}
