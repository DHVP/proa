import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class Reminder {
  final String id, title, body, label;
  bool on;
  TimeOfDay time;
  Reminder(this.id, this.title, this.body, this.label, this.time, {this.on = true});

  Map<String, dynamic> toJson() => {'on': on, 'h': time.hour, 'm': time.minute};
  void load(Map? j) {
    if (j == null) return;
    on = j['on'] ?? on;
    time = TimeOfDay(hour: j['h'] ?? time.hour, minute: j['m'] ?? time.minute);
  }
}

List<Reminder> defaultReminders() => [
  Reminder(
    'agua',
    'Tomar agua',
    'Un vaso más suma a tu meta de hoy',
    'Cada 2 horas desde las',
    const TimeOfDay(hour: 8, minute: 0),
  ),
  Reminder(
    'comidas',
    'Registrar comidas',
    'Anota lo que comiste en el almuerzo',
    'Todos los días a las',
    const TimeOfDay(hour: 14, minute: 0),
  ),
  Reminder(
    'actividad',
    'Actividad física',
    'Es buen momento para moverte un rato',
    'Todos los días a las',
    const TimeOfDay(hour: 18, minute: 0),
  ),
  Reminder(
    'resumen',
    'Tu día en PROA',
    'Revisa cómo te fue hoy con tus hábitos',
    'Resumen diario a las',
    const TimeOfDay(hour: 20, minute: 0),
  ),
  Reminder(
    'dormir',
    'Prepárate para dormir',
    'Deja las pantallas y descansa',
    'Todas las noches a las',
    const TimeOfDay(hour: 21, minute: 30),
  ),
];

final _plugin = FlutterLocalNotificationsPlugin();

Future<void> initReminders() async {
  tzdata.initializeTimeZones();
  // ponytail: PROA es para Colombia, si sale del país se cambia por flutter_timezone
  tz.setLocalLocation(tz.getLocation('America/Bogota'));
  await _plugin.initialize(
    settings: const InitializationSettings(android: AndroidInitializationSettings('@drawable/ic_launcher_foreground')),
  );
}

Future<bool> askNotificationPermission() async =>
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() ??
    false;

Future<void> scheduleReminders(bool enabled, List<Reminder> list) async {
  await _plugin.cancelAll();
  if (!enabled) return;
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'recordatorios',
      'Recordatorios',
      channelDescription: 'Recordatorios de tus hábitos',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );
  var id = 0;
  for (final r in list.where((r) => r.on)) {
    // el agua se repite cada 2 horas hasta las 8 de la noche
    final hours = r.id == 'agua' ? [for (var h = r.time.hour; h <= 20; h += 2) h] : [r.time.hour];
    for (final h in hours) {
      await _plugin.zonedSchedule(
        id: id++,
        title: r.title,
        body: r.body,
        scheduledDate: _next(h, r.time.minute),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}

tz.TZDateTime _next(int h, int m) {
  final now = tz.TZDateTime.now(tz.local);
  var t = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
  if (!t.isAfter(now)) t = t.add(const Duration(days: 1));
  return t;
}
