import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'home.dart' show cap;
import 'start.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // franja bajo la barra de estado cuando la cabecera verde ya salió de la pantalla
  bool scrolled = false;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      NotificationListener<ScrollNotification>(
        onNotification: (n) {
          final s = n.metrics.pixels > 200;
          if (s != scrolled) setState(() => scrolled = s);
          return false;
        },
        child: _list(context),
      ),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: AnimatedOpacity(
          opacity: scrolled ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: Container(height: MediaQuery.paddingOf(context).top, color: C.bg),
        ),
      ),
    ],
  );

  Widget _list(BuildContext context) {
    final p = app.profile!;
    final t = today();
    final ws = weekStart(t);
    final top = MediaQuery.paddingOf(context).top;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: G.hero,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            boxShadow: S.colored(C.teal),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -70,
                top: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: const BoxDecoration(color: Color(0x14FFFFFF), shape: BoxShape.circle),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, top + 12, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Mi perfil',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Editar perfil',
                          onPressed: () => push(context, const EditProfileScreen()),
                          style: IconButton.styleFrom(backgroundColor: const Color(0x26FFFFFF)),
                          icon: const Icon(LucideIcons500.pencil, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Semantics(
                          container: true,
                          button: true,
                          label: 'Editar perfil y foto',
                          child: GestureDetector(
                            onTap: () => push(context, const EditProfileScreen()),
                            child: const Avatar(size: 84),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: title(26, color: Colors.white),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text('${p.age} años', style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 14.5)),
                              const SizedBox(height: 8),
                              Pill(
                                'Objetivo: ${optionById(goals, p.goal).hint}',
                                color: Colors.white,
                                icon: LucideIcons500.target,
                                background: const Color(0x26FFFFFF),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _stat('${app.streak()}', app.streak() == 1 ? 'Día seguido' : 'Días seguidos'),
                        const SizedBox(width: 10),
                        _stat('${app.doneCount(t)}/${app.plan.length}', 'Hoy'),
                        const SizedBox(width: 10),
                        _stat('${app.percent(ws, DateTime(ws.year, ws.month, ws.day + 6))} %', 'Semana'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle('Tu información'),
              Panel(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    _info(LucideIcons500.target, 'Objetivo', optionById(goals, p.goal).label),
                    _info(LucideIcons500.activity, 'Actividad física', optionById(activities, p.activity).label),
                    _info(LucideIcons500.calendar, 'En PROA desde', cap(DateFormat('MMMM yyyy', 'es').format(p.since))),
                    if (app.answers != null)
                      _info(LucideIcons500.listChecks, 'Último test', '${totalScore(app.answers!)} de 100'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Panel(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    _link(
                      context,
                      LucideIcons500.pencil,
                      C.muted,
                      'Editar perfil',
                      'Nombre, edad, actividad y objetivo',
                      const EditProfileScreen(),
                    ),
                    _link(
                      context,
                      LucideIcons500.sprout,
                      C.green,
                      'Mis hábitos',
                      'Elige qué hábitos van en tu plan',
                      const MyHabitsScreen(),
                    ),
                    _link(
                      context,
                      LucideIcons500.refreshCw,
                      const Color(0xFF0E8FB0),
                      'Repetir el test',
                      'Actualiza tu plan según cómo vas',
                      const TestScreen(retake: true),
                    ),
                    _link(
                      context,
                      LucideIcons500.bell,
                      C.orange,
                      'Recordatorios',
                      app.remindersOn ? 'Activados' : 'Desactivados',
                      const RemindersScreen(),
                    ),
                    _link(
                      context,
                      LucideIcons500.lock,
                      const Color(0xFF4F5BD5),
                      'Privacidad',
                      'Qué guardamos y cómo borrarlo',
                      const PrivacyScreen(),
                    ),
                    _link(
                      context,
                      LucideIcons500.circleHelp,
                      const Color(0xFF7A4FC4),
                      'Ayuda',
                      'Preguntas frecuentes',
                      const HelpScreen(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Btn(
                'Cerrar sesión',
                icon: LucideIcons500.logOut,
                tone: Tone.danger,
                onPressed: () async {
                  if (await confirm(
                    context,
                    heading: '¿Cerrar sesión?',
                    body: 'Tu progreso queda guardado en tu cuenta y lo verás al volver a entrar',
                    ok: 'Salir',
                    danger: true,
                    icon: LucideIcons500.logOut,
                  )) {
                    await app.signOut();
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'PROA es una herramienta educativa y no reemplaza la consulta médica',
                textAlign: TextAlign.center,
                style: TextStyle(color: C.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(String value, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFeatures: tabular,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Color(0xD9FFFFFF), fontSize: 12.5)),
        ],
      ),
    ),
  );

  Widget _info(IconData icon, String label, String value) => ListTile(
    leading: Icon(icon, color: C.faint, size: 20),
    title: Text(label, style: const TextStyle(color: C.muted, fontSize: 15)),
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 190),
      child: Text(
        value,
        textAlign: TextAlign.end,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
  );

  Widget _link(BuildContext context, IconData icon, Color color, String head, String sub, Widget page) => ListTile(
    onTap: () => push(context, page),
    leading: IconTile(icon, color, size: 42),
    title: Text(head, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
    subtitle: Text(sub, style: const TextStyle(color: C.muted)),
    trailing: const Icon(LucideIcons500.chevronRight, color: C.muted),
  );
}

// ---------- Editar perfil ----------

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late bool google = app.profile!.googlePhoto;
  late Uint8List? photo = app.profile!.photo;

  ImageProvider? get preview => photo != null
      ? MemoryImage(photo!)
      : google && app.account?.photo != null
      ? NetworkImage(app.account!.photo!)
      : null;

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source, maxWidth: 400, maxHeight: 400, imageQuality: 75);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 300 * 1024) return toast('Esa imagen es muy pesada, prueba con otra');
      setState(() => photo = bytes);
    } catch (_) {
      toast('No pudimos abrir la ${source == ImageSource.camera ? 'cámara' : 'galería'}');
    }
  }

  void _options() => showModalBottomSheet(
    context: context,
    builder: (ctx) {
      Widget item(IconData icon, String text, VoidCallback onTap, {Color color = C.ink}) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: Icon(icon, color: color),
        title: Text(
          text,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: color),
        ),
        onTap: () {
          Navigator.pop(ctx);
          onTap();
        },
      );
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text('Foto de perfil', style: title(22)),
            ),
            item(LucideIcons500.image, 'Elegir de la galería', () => _pick(ImageSource.gallery)),
            item(LucideIcons500.camera, 'Tomar una foto', () => _pick(ImageSource.camera)),
            if (app.account?.photo != null)
              item(
                LucideIcons500.user,
                'Usar la foto de Google',
                () => setState(() {
                  photo = null;
                  google = true;
                }),
              ),
            if (preview != null)
              item(
                LucideIcons500.trash2,
                'Quitar foto',
                () => setState(() {
                  photo = null;
                  google = false;
                }),
                color: C.red,
              ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          const Header('Editar perfil', sub: 'Actualiza tu información cuando quieras'),
          Semantics(
            container: true,
            button: true,
            label: 'Cambiar foto de perfil',
            child: GestureDetector(
              onTap: _options,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: C.greenSoft,
                    foregroundImage: preview,
                    child: Text(app.firstName.isEmpty ? '?' : app.firstName[0], style: title(44, color: C.green)),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: C.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: C.bg, width: 3),
                      ),
                      child: const Icon(LucideIcons500.camera, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton(onPressed: _options, child: const Text('Cambiar foto')),
          Expanded(
            child: ProfileForm(
              initial: app.profile,
              action: 'Guardar cambios',
              onSave: (p) {
                p.googlePhoto = google;
                p.photo = photo;
                final activityChanged = p.activity != app.profile!.activity;
                app.saveProfile(p);
                Navigator.pop(context);
                toast(activityChanged ? 'Cambios guardados, tu meta de actividad se ajustó' : 'Cambios guardados');
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// ---------- Mis hábitos ----------

class MyHabitsScreen extends StatelessWidget {
  const MyHabitsScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            Header('Mis hábitos', sub: 'Elige qué hábitos van en tu plan diario, tienes ${app.plan.length} activos'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Panel(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        for (final h in habits)
                          SwitchListTile(
                            value: app.plan.contains(h.id),
                            onChanged: (_) => app.togglePlan(h.id),
                            activeThumbColor: C.green,
                            secondary: IconTile(h.icon, h.color, size: 42),
                            title: Text(h.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            subtitle: Text(
                              app.streak(h.id) > 0
                                  ? '${cap(app.goal(h.id))}, racha de ${app.streak(h.id)}'
                                  : cap(app.goal(h.id)),
                              style: const TextStyle(color: C.muted),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Desactivar un hábito no borra su historial y puedes volver a activarlo cuando quieras',
                    style: TextStyle(color: C.muted, fontSize: 14.5, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------- Recordatorios ----------

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const Header('Recordatorios', sub: 'Elige cuándo quieres que PROA te avise en el teléfono'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Panel(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SwitchListTile(
                      value: app.remindersOn,
                      onChanged: app.setReminders,
                      activeThumbColor: C.green,
                      title: const Text('Recordatorios', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                      subtitle: Text(
                        app.remindersOn ? 'Activados' : 'Desactivados',
                        style: const TextStyle(color: C.muted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: app.remindersOn ? 1 : .45,
                    child: Panel(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          for (final r in app.reminders)
                            ListTile(
                              enabled: app.remindersOn,
                              title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              subtitle: InkWell(
                                onTap: !app.remindersOn
                                    ? null
                                    : () async {
                                        final t = await showTimePicker(
                                          context: context,
                                          initialTime: r.time,
                                          helpText: 'Elige la hora',
                                          cancelText: 'Cancelar',
                                          confirmText: 'Listo',
                                        );
                                        if (t != null) await app.updateReminder(r, time: t);
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(text: '${r.label} '),
                                        TextSpan(
                                          text: clock(r.time.hour, r.time.minute),
                                          style: const TextStyle(
                                            color: C.green,
                                            fontWeight: FontWeight.w700,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              trailing: Switch(
                                value: r.on,
                                activeThumbColor: C.green,
                                onChanged: app.remindersOn ? (v) => app.updateReminder(r, on: v) : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Toca la hora para cambiarla, los avisos llegan aunque la app esté cerrada',
                    style: TextStyle(color: C.muted, fontSize: 14.5, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------- Privacidad ----------

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final days = app.logs.values.where((m) => m.isNotEmpty).length;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            const Header('Privacidad', sub: 'Tus datos son tuyos'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _item(
                          LucideIcons500.shieldCheck,
                          'Guardados en tu cuenta',
                          'Tu perfil, el test y tus registros quedan ligados a tu cuenta de Google y solo tú puedes verlos',
                        ),
                        _item(
                          LucideIcons500.info,
                          'Sin diagnósticos',
                          'El test es una herramienta educativa de orientación y no reemplaza una valoración médica',
                        ),
                        _item(
                          LucideIcons500.listChecks,
                          'Lo que hay guardado',
                          'Perfil, resultado del test, $days ${days == 1 ? 'día' : 'días'} con registros, ${app.cravings.length} ${app.cravings.length == 1 ? 'antojo' : 'antojos'} y ${app.saved.length} ${app.saved.length == 1 ? 'guía guardada' : 'guías guardadas'}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Btn(
                    'Borrar todos mis datos',
                    icon: LucideIcons500.trash2,
                    tone: Tone.danger,
                    onPressed: () async {
                      if (await confirm(
                        context,
                        heading: '¿Borrar todos tus datos?',
                        body: 'Se elimina tu perfil, el test y todo tu historial, esto no se puede deshacer',
                        ok: 'Borrar',
                        danger: true,
                        icon: LucideIcons500.trash2,
                      )) {
                        await app.deleteAll();
                        toast('Tus datos fueron borrados');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String head, String body) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(icon, C.green, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(head, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 2),
              Text(body, style: const TextStyle(color: C.muted, fontSize: 15, height: 1.4)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ---------- Ayuda ----------

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  static const faq = [
    (
      '¿El test es un diagnóstico médico?',
      'No, es una herramienta educativa que te orienta sobre tus hábitos, para un diagnóstico consulta a un profesional de salud',
    ),
    (
      '¿Cómo se calcula mi puntaje?',
      'Cada respuesta suma puntos según qué tan saludable es el hábito, el total va de 0 a 100 y también se calcula por áreas',
    ),
    (
      '¿Por qué mi plan es distinto al de otra persona?',
      'Tu plan sale de tus respuestas y tu objetivo, PROA elige los hábitos donde más puedes mejorar y ajusta las metas a tu punto de partida',
    ),
    (
      '¿Cómo marco un hábito?',
      'Toca la casilla en Inicio o en Plan, o entra al hábito para registrar vasos, porciones o comidas',
    ),
    (
      '¿Puedo cambiar los hábitos de mi plan?',
      'Sí, ve a Perfil y luego a Mis hábitos, o toca Editar en Plan, también puedes repetir el test',
    ),
    (
      '¿Qué pasa si un día no cumplo?',
      'Nada grave, un paso pequeño cada día cuenta más que un cambio grande que no puedes sostener',
    ),
    (
      '¿Dónde se guardan mis datos?',
      'En tu cuenta, así los ves en cualquier teléfono donde entres con Google, puedes borrarlos desde Perfil en Privacidad',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          const Header('Ayuda', sub: 'Preguntas frecuentes sobre PROA'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Panel(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (final (q, a) in faq)
                    ExpansionTile(
                      shape: const Border(),
                      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      expandedAlignment: Alignment.centerLeft,
                      children: [Text(a, style: const TextStyle(color: C.muted, fontSize: 15.5, height: 1.45))],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
