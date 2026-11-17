import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

// ---------- Bienvenida ----------

const welcomeGreen = Color(0xFF0B4A2A);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: welcomeGreen,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: w * 1.2,
            child: Image.asset('assets/images/bienvenida.jpg', fit: BoxFit.cover, alignment: const Alignment(.2, -1)),
          ),
          Positioned(
            top: w * .78,
            left: 0,
            right: 0,
            height: w * .43,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x000D4F2A), welcomeGreen],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(LucideIcons500.sprout, color: Colors.white, size: 30),
                      const SizedBox(width: 10),
                      Text('PROA', style: title(30, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Prevención y reeducación en obesidad y alimentación',
                    style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14.5),
                  ),
                  const SizedBox(height: 26),
                  Text('Pequeños hábitos, grandes cambios', style: title(44, color: Colors.white)),
                  const SizedBox(height: 14),
                  const Text(
                    'Un test de 3 minutos y un plan diario que cabe en tu rutina',
                    style: TextStyle(color: Color(0xE6FFFFFF), fontSize: 17.5, height: 1.4),
                  ),
                  const SizedBox(height: 30),
                  Btn(
                    'Comenzar',
                    icon: LucideIcons500.arrowRight,
                    tone: Tone.light,
                    onPressed: () async => push(context, const IntroScreen()),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: TextButton(
                      onPressed: app.signInWithGoogle,
                      style: TextButton.styleFrom(foregroundColor: Colors.white, minimumSize: const Size(48, 48)),
                      child: const Text.rich(
                        TextSpan(
                          style: TextStyle(fontSize: 16, color: Color(0xE6FFFFFF)),
                          children: [
                            TextSpan(text: '¿Ya tienes cuenta? '),
                            TextSpan(
                              text: 'Inicia sesión',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Herramienta educativa, no reemplaza la consulta médica',
                      style: TextStyle(color: Color(0x99FFFFFF), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Introducción ----------

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final pages = PageController();
  int page = 0;
  // como en Figma, cada paso tiene su color
  static const accents = [C.green, C.turq, C.orange];
  static const tones = [Tone.primary, Tone.secondary, Tone.accent];
  static const steps = [
    (LucideIcons500.search, 'diagnóstico'),
    (LucideIcons500.sprout, 'rutina'),
    (LucideIcons500.trendingUp, 'progreso'),
  ];
  static const slides = [
    ('bowl_saludable', 'Conoce tus hábitos', 'Un test corto y sencillo te muestra cómo están tus hábitos hoy'),
    (
      'cocinando_en_casa',
      'Crea una rutina saludable',
      'Tu plan reúne acciones pequeñas que puedes sostener sin esfuerzo extremo',
    ),
    ('actividad_fisica', 'Avanza a tu ritmo', 'Registra tus avances y construye constancia un día a la vez'),
  ];

  @override
  Widget build(BuildContext context) {
    final last = page == slides.length - 1;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: pages,
              onPageChanged: (i) => setState(() => page = i),
              children: [
                for (final (i, (img, head, body)) in slides.indexed)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 11,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                                child: Image.asset('assets/images/$img.jpg', fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: 20,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(99),
                                  boxShadow: S.soft,
                                ),
                                child: Row(
                                  children: [
                                    IconTile(steps[i].$1, accents[i], size: 28, filled: true),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Paso ${i + 1} de 3, ${steps[i].$2}',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(head, style: title(34)),
                              const SizedBox(height: 12),
                              Text(body, style: const TextStyle(color: C.muted, fontSize: 17, height: 1.45)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < slides.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == page ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == page ? accents[page] : C.line,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
            ],
          ),
          BottomAction(
            Column(
              children: [
                if (last) ...[
                  GoogleButton(onPressed: app.signInWithGoogle),
                  const SizedBox(height: 10),
                  const Text(
                    'Tu progreso queda guardado en tu cuenta y solo tú lo ves',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: C.muted, fontSize: 14),
                  ),
                ] else ...[
                  Btn(
                    'Continuar',
                    tone: tones[page],
                    icon: LucideIcons500.arrowRight,
                    onPressed: () =>
                        pages.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic),
                  ),
                  TextButton(
                    onPressed: () => pages.animateToPage(
                      slides.length - 1,
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutCubic,
                    ),
                    child: const Text('Saltar', style: TextStyle(color: C.muted, fontSize: 15)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  const GoogleButton({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: S.raised),
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: C.ink,
        side: const BorderSide(color: C.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 22, height: 22, child: CustomPaint(painter: _GoogleG())),
          SizedBox(width: 12),
          Text('Continuar con Google', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        ],
      ),
    ),
  );
}

class _GoogleG extends CustomPainter {
  const _GoogleG();
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width * .2;
    final r = Rect.fromLTWH(w / 2, w / 2, s.width - w, s.height - w);
    Paint p(int c) => Paint()
      ..color = Color(c)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;
    const d = math.pi / 180;
    canvas.drawArc(r, -40 * d, -100 * d, false, p(0xFFEA4335));
    canvas.drawArc(r, -140 * d, -90 * d, false, p(0xFFFBBC05));
    canvas.drawArc(r, 130 * d, -95 * d, false, p(0xFF34A853));
    canvas.drawArc(r, 35 * d, -35 * d, false, p(0xFF4285F4));
    canvas.drawRect(
      Rect.fromLTWH(s.width / 2, s.height / 2 - w / 2, s.width / 2 - w / 4, w),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------- Perfil inicial ----------

class StepBar extends StatelessWidget {
  final String text;
  final double value;
  const StepBar(this.text, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: const TextStyle(color: C.green, fontWeight: FontWeight.w700, fontSize: 14),
      ),
      const SizedBox(height: 8),
      Container(
        height: 7,
        decoration: BoxDecoration(color: C.line, borderRadius: BorderRadius.circular(9)),
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => FractionallySizedBox(
            widthFactor: v,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [C.green, C.turq]),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class ProfileForm extends StatefulWidget {
  final Profile? initial;
  final void Function(Profile p) onSave;
  final String action;
  const ProfileForm({super.key, this.initial, required this.onSave, required this.action});
  @override
  State<ProfileForm> createState() => ProfileFormState();
}

class ProfileFormState extends State<ProfileForm> {
  late final name = TextEditingController(text: widget.initial?.name ?? app.account?.name ?? '');
  late final age = TextEditingController(text: widget.initial?.age.toString() ?? '');
  late String? sex = widget.initial?.sex;
  late String? activity = widget.initial?.activity;
  late String? goal = widget.initial?.goal;

  int? get ageValue => int.tryParse(age.text);
  bool get ageOk => ageValue != null && ageValue! >= 18 && ageValue! <= 100;
  bool get valid => name.text.trim().isNotEmpty && ageOk && sex != null && activity != null && goal != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const Label('Tu nombre'),
              TextField(
                controller: name,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Cómo quieres que te llamemos',
                  prefixIcon: Icon(LucideIcons500.user),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Label('Edad'),
                        TextField(
                          controller: age,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Años',
                            prefixIcon: const Icon(LucideIcons500.calendar),
                            errorText: age.text.isNotEmpty && !ageOk ? 'Desde 18 años' : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Label('Sexo'),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            final v = await pickOne(context, 'Sexo', sexes, sex);
                            if (v != null) setState(() => sex = v);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(LucideIcons500.user),
                              suffixIcon: Icon(LucideIcons500.chevronDown),
                            ),
                            child: Text(
                              sexes[sex] ?? 'Elegir',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, color: sex == null ? C.muted : C.ink),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Label('Nivel de actividad física'),
              GridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [for (final o in activities) _choice(o)],
              ),
              const Label('Objetivo principal'),
              Panel(
                padding: EdgeInsets.zero,
                child: RadioGroup<String>(
                  groupValue: goal,
                  onChanged: (v) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() => goal = v);
                  },
                  child: Column(
                    children: [
                      for (final o in goals)
                        RadioListTile<String>(
                          value: o.id,
                          controlAffinity: ListTileControlAffinity.trailing,
                          secondary: IconTile(o.icon, goal == o.id ? C.green : C.muted, size: 38),
                          title: Text(o.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        BottomAction(
          Btn(widget.action, icon: LucideIcons500.arrowRight, onPressed: valid ? () async => _save() : null),
        ),
      ],
    );
  }

  void _save() {
    final i = widget.initial;
    widget.onSave(
      Profile(
        name: name.text.trim(),
        age: ageValue!,
        sex: sex!,
        activity: activity!,
        goal: goal!,
        googlePhoto: i?.googlePhoto ?? true,
        photo: i?.photo,
        since: i?.since,
      ),
    );
  }

  Widget _choice(Option o) {
    final on = activity == o.id;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: on ? const Color(0xFFF0FDF4) : C.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: on ? C.green : C.line, width: on ? 2 : 1),
        boxShadow: on ? S.colored(C.green) : S.soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => activity = o.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    on ? IconTile(o.icon, C.green, size: 36, filled: true) : IconTile(o.icon, C.muted, size: 36),
                    const Spacer(),
                    if (on) const Icon(LucideIcons500.circleCheck, color: C.green, size: 22),
                  ],
                ),
                const Spacer(),
                Text(
                  o.label,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: on ? C.greenDeep : C.ink),
                ),
                Text(o.hint, style: const TextStyle(color: C.muted, fontSize: 13.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CreateProfileScreen extends StatelessWidget {
  const CreateProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(
              children: [
                const Expanded(child: StepBar('Paso 1 de 2', .5)),
                const SizedBox(width: 12),
                TextButton(onPressed: app.signOut, child: const Text('Cambiar de cuenta')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cuéntanos sobre ti', style: title(32)),
                const SizedBox(height: 6),
                const Text('Con esto armamos un plan a tu medida', style: TextStyle(color: C.muted, fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: ProfileForm(
              initial: app.profile,
              action: 'Continuar al test',
              onSave: (p) {
                app.saveProfile(p);
                push(context, const TestScreen());
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// ---------- Test ----------

class TestScreen extends StatefulWidget {
  final bool retake;
  const TestScreen({super.key, this.retake = false});
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final answers = <int>[];
  int q = 0;
  int? picked;

  void _pick(int i) async {
    setState(() => picked = i);
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    if (answers.length > q) {
      answers[q] = i;
    } else {
      answers.add(i);
    }
    if (q == questions.length - 1) {
      app.saveTest(answers);
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TestResultScreen(retake: widget.retake)));
      return;
    }
    setState(() {
      q++;
      picked = answers.length > q ? answers[q] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[q];
    return PopScope(
      canPop: q == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => picked = answers[--q]);
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                children: [
                  const BackBtn(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: StepBar(
                      widget.retake
                          ? 'Pregunta ${q + 1} de ${questions.length}'
                          : 'Paso 2 de 2, pregunta ${q + 1} de ${questions.length}',
                      (q + 1) / questions.length,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerLeft,
                child: Pill(question.area, icon: question.icon),
              ),
              const SizedBox(height: 14),
              Text(question.text, style: title(28)),
              if (question.examples != null) ...[
                const SizedBox(height: 14),
                Callout(question.examples!, icon: LucideIcons500.info, heading: 'Ejemplos'),
              ],
              const SizedBox(height: 10),
              const Text('Elige la opción que mejor te describe', style: TextStyle(color: C.muted, fontSize: 15.5)),
              const SizedBox(height: 18),
              for (final (i, o) in question.options.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Panel(
                    color: picked == i ? const Color(0xFFF0FDF4) : C.surface,
                    borderColor: picked == i ? C.green : null,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    onTap: () => _pick(i),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: picked == i ? G.primary : null,
                            color: picked == i ? null : C.field,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'ABCD'[i],
                            style: TextStyle(fontWeight: FontWeight.w700, color: picked == i ? Colors.white : C.muted),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            o,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: picked == i ? C.greenDeep : C.ink,
                            ),
                          ),
                        ),
                        Icon(
                          picked == i ? LucideIcons500.circleCheck : LucideIcons500.chevronRight,
                          color: picked == i ? C.green : C.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons500.lock, size: 15, color: C.muted),
                  SizedBox(width: 6),
                  Text('Tus respuestas son privadas', style: TextStyle(color: C.muted, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color levelColor(int v) => v >= 70
    ? C.green
    : v >= 50
    ? C.amber
    : v >= 30
    ? C.orange
    : C.red;

class TestResultScreen extends StatelessWidget {
  final bool retake;
  const TestResultScreen({super.key, this.retake = false});

  @override
  Widget build(BuildContext context) {
    final a = app.answers!;
    final score = totalScore(a);
    final (head, body) = resultText(score);
    final focus = [...app.plan]
      ..sort((x, y) {
        int p(String id) => habitById(id).question < 0 ? 2 : points(a, habitById(id).question);
        return p(x).compareTo(p(y));
      });
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  const Text(
                    'Tu resultado',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: C.muted, fontSize: 16),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: S.raised),
                      child: Ring(
                        value: score / 100,
                        size: 150,
                        stroke: 12,
                        color: levelColor(score),
                        track: soft(levelColor(score)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$score', style: title(52)),
                            const Text('de 100', style: TextStyle(color: C.muted, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(head, textAlign: TextAlign.center, style: title(28)),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: C.muted, fontSize: 16.5, height: 1.4),
                  ),
                  const SectionTitle('Tu perfil por áreas'),
                  Panel(child: Column(children: [for (final e in areas.entries) _area(e.key, areaScore(a, e.value))])),
                  const SectionTitle('Tu plan empieza por aquí'),
                  Panel(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        for (final id in focus.take(3))
                          ListTile(
                            leading: IconTile(habitById(id).icon, habitById(id).color, size: 44, filled: true),
                            title: Text(habitById(id).advice, style: const TextStyle(fontSize: 15.5, height: 1.35)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Callout(
                    'Este test es una herramienta educativa de orientación, no es un diagnóstico ni reemplaza una valoración médica',
                    icon: LucideIcons500.shieldCheck,
                  ),
                ],
              ),
            ),
            BottomAction(
              Btn(
                retake ? 'Ver mi plan actualizado' : 'Ver mi plan',
                icon: LucideIcons500.arrowRight,
                tone: Tone.secondary,
                onPressed: () async {
                  // recordatorios encendidos desde el inicio, Android pide el permiso aquí
                  if (!retake && !app.remindersOn) await app.setReminders(true);
                  app.setTab(1);
                  if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _area(String name, int v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(name, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
            ),
            Text(
              '$v %',
              style: TextStyle(fontWeight: FontWeight.w700, color: levelColor(v), fontFeatures: tabular),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: LinearProgressIndicator(value: v / 100, minHeight: 9, color: levelColor(v), backgroundColor: C.field),
        ),
      ],
    ),
  );
}
