import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import '../data.dart';
import '../reminders.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'habit.dart';
import 'nutrition.dart';
import 'profile.dart';
import 'progress.dart';

String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
String longDate(DateTime d) => cap(DateFormat("EEEE d 'de' MMMM", 'es').format(d));
String shortDate(DateTime d) => cap(DateFormat("EEEE d MMM", 'es').format(d).replaceAll('.', ''));

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => PopScope(
      canPop: app.tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) app.setTab(0);
      },
      child: Scaffold(
        // sin const a propósito: así cada pestaña se redibuja cuando cambia el estado
        // ignore: prefer_const_constructors
        body: [HomeTab(), PlanTab(), NutritionTab(), ProgressTab(), ProfileTab()][app.tab],
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: Color(0x0F111827), blurRadius: 20, offset: Offset(0, -4))],
          ),
          child: NavigationBar(
            selectedIndex: app.tab,
            onDestinationSelected: app.setTab,
            destinations: const [
              NavigationDestination(icon: Icon(LucideIcons500.house), label: 'Inicio'),
              NavigationDestination(icon: Icon(LucideIcons500.calendarCheck), label: 'Plan'),
              NavigationDestination(icon: Icon(LucideIcons500.mapPinPlus), label: 'Alimentación'),
              NavigationDestination(icon: Icon(LucideIcons500.chartColumn), label: 'Progreso'),
              NavigationDestination(icon: Icon(LucideIcons500.user), label: 'Perfil'),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Lista de hábitos dentro de un panel, con divisores
Widget habitList(BuildContext context, DateTime day, {bool editable = true}) => Panel(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Column(
    children: [
      for (final (i, id) in app.plan.indexed) ...[
        if (i > 0) const Divider(indent: 16, endIndent: 16),
        HabitRow(id, day, editable: editable, onOpen: () => push(context, HabitScreen(id, day))),
      ],
    ],
  ),
);

Widget cravingCard(BuildContext context) => Panel(
  color: const Color(0xFFFFF7ED),
  borderColor: const Color(0xFFFED7AA),
  onTap: () => push(context, const CravingsScreen()),
  child: const Row(
    children: [
      IconTile(LucideIcons500.heart, C.orange, size: 46, filled: true),
      SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Sientes ansiedad o un antojo?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            SizedBox(height: 2),
            Text(
              'Registra cómo te sientes y prueba una idea',
              style: TextStyle(color: Color(0xFF9A3412), fontSize: 14),
            ),
          ],
        ),
      ),
      Icon(LucideIcons500.chevronRight, color: C.orange),
    ],
  ),
);

Widget emptyPlan(BuildContext context) => Panel(
  child: Column(
    children: [
      const IconTile(LucideIcons500.listChecks, C.green, size: 56, filled: true),
      const SizedBox(height: 12),
      const Text('No tienes hábitos activos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      const SizedBox(height: 4),
      const Text('Elige al menos uno para empezar tu plan', style: TextStyle(color: C.muted)),
      const SizedBox(height: 14),
      Btn('Elegir hábitos', onPressed: () async => push(context, const MyHabitsScreen())),
    ],
  ),
);

List<Reminder> dueReminders() {
  if (!app.remindersOn) return const [];
  final now = TimeOfDay.now();
  return app.reminders.where((r) => r.on && r.time.hour * 60 + r.time.minute <= now.hour * 60 + now.minute).toList();
}

// ---------- Inicio ----------

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  String get greeting {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Buenos días'
        : h < 19
        ? 'Buenas tardes'
        : 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final day = today();
    final done = app.doneCount(day), total = app.plan.length, streak = app.streak();
    final pct = total == 0 ? 0 : (done * 100 / total).round();
    final message = total == 0
        ? 'Elige tus hábitos para empezar'
        : done == 0
        ? 'Empieza con el hábito más fácil'
        : done == total
        ? 'Completaste todo tu plan de hoy'
        : '¡Vas muy bien! Te ${total - done == 1 ? 'falta 1' : 'faltan ${total - done}'}';
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(
            children: [
              GestureDetector(onTap: () => app.setTab(4), child: const Avatar(size: 54)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(greeting, style: const TextStyle(color: C.muted, fontSize: 15.5)),
                    Text(app.firstName, style: title(26), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Stack(
                children: [
                  RoundBtn(LucideIcons500.bell, tooltip: 'Avisos', onPressed: () => showNotifications(context)),
                  if (dueReminders().isNotEmpty)
                    Positioned(
                      right: 12,
                      top: 11,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: C.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(
                streak == 1 ? '1 día seguido' : '$streak días seguidos',
                color: C.orange,
                icon: LucideIcons500.flame,
                background: C.orangeSoft,
              ),
              Pill(shortDate(day), color: C.body, icon: LucideIcons500.calendar, background: Colors.white),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: G.hero,
              borderRadius: BorderRadius.circular(26),
              boxShadow: S.colored(C.teal),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -50,
                  top: -60,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: const BoxDecoration(color: Color(0x14FFFFFF), shape: BoxShape.circle),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 18, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$done de $total hábitos completados', style: title(26, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(message, style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 15)),
                            const SizedBox(height: 16),
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(99),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(99),
                                onTap: () => app.setTab(1),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Ver mi plan',
                                        style: TextStyle(color: C.greenDeep, fontWeight: FontWeight.w700, fontSize: 15),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(LucideIcons500.arrowRight, color: C.greenDeep, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Ring(
                        value: total == 0 ? 0 : done / total,
                        size: 96,
                        stroke: 10,
                        color: Colors.white,
                        track: const Color(0x33FFFFFF),
                        child: Text(
                          '$pct %',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 21,
                            fontFeatures: tabular,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SectionTitle('Hábitos de hoy', action: 'Ver todo', onAction: () => app.setTab(1)),
          if (app.plan.isEmpty) emptyPlan(context) else habitList(context, day),
          SectionTitle('Guías para ti', action: 'Ver todas', onAction: () => app.setTab(2)),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: guidesForPlan().length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => SizedBox(width: 220, child: GuideCard(guidesForPlan()[i])),
            ),
          ),
          const SizedBox(height: 20),
          cravingCard(context),
        ],
      ),
    );
  }
}

/// Guías ordenadas según los hábitos del plan
List<Guide> guidesForPlan() {
  const link = {
    'agua': 'hidratacion',
    'azucar': 'ultra',
    'ultra': 'ultra',
    'frutas': 'frutas',
    'registro': 'porciones',
    'desayuno': 'plato',
  };
  final first = {for (final id in app.plan) ?link[id]};
  return [...first.map(guideById), ...guides.where((g) => !first.contains(g.id))];
}

void showNotifications(BuildContext context) {
  final due = dueReminders();
  final tip = tips[DateTime.now().difference(DateTime(2026)).inDays % tips.length];
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Avisos', style: title(24)),
            const SizedBox(height: 14),
            _notice(LucideIcons500.sparkles, C.green, 'Consejo del día', tip),
            for (final r in due.reversed)
              _notice(LucideIcons500.bellRing, C.orange, r.title, r.body, clock(r.time.hour, r.time.minute)),
            if (!app.remindersOn)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Btn(
                  'Activar recordatorios',
                  icon: LucideIcons500.bell,
                  tone: Tone.outline,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    push(context, const RemindersScreen());
                  },
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _notice(IconData icon, Color color, String head, String body, [String? time]) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Panel(
    color: C.field,
    padding: const EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(icon, color, size: 42, filled: true),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(head, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                  ),
                  if (time != null) Text(time, style: const TextStyle(color: C.muted, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 2),
              Text(body, style: const TextStyle(color: C.body, fontSize: 14.5, height: 1.35)),
            ],
          ),
        ),
      ],
    ),
  ),
);

// ---------- Plan ----------

class PlanTab extends StatefulWidget {
  const PlanTab({super.key});
  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {
  DateTime day = today();

  @override
  Widget build(BuildContext context) {
    final start = weekStart(day);
    final future = day.isAfter(today());
    final done = app.doneCount(day), total = app.plan.length, left = total - done;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(longDate(day), style: const TextStyle(color: C.muted, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(day == today() ? 'Mi plan de hoy' : 'Mi plan', style: title(32)),
                  ],
                ),
              ),
              RoundBtn(LucideIcons500.calendar, tooltip: 'Elegir fecha', onPressed: _pickDate),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(child: _dayChip(DateTime(start.year, start.month, start.day + i))),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Panel(
            child: Row(
              children: [
                Ring(
                  value: future || total == 0 ? 0 : done / total,
                  size: 78,
                  stroke: 8,
                  child: Text(
                    future || total == 0 ? '0 %' : '${(done * 100 / total).round()} %',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, fontFeatures: tabular),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        future ? 'Este día aún no llega' : '$done de $total hábitos',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        future
                            ? 'Podrás registrarlo cuando llegue'
                            : total == 0
                            ? 'Activa hábitos para armar tu plan'
                            : left == 0
                            ? '¡Completaste todos tus hábitos!'
                            : 'Te ${left == 1 ? 'falta 1' : 'faltan $left'} para completar el día',
                        style: const TextStyle(color: C.muted, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SectionTitle(
            day == today() ? 'Acciones de hoy' : 'Acciones del día',
            action: 'Editar',
            onAction: () => push(context, const MyHabitsScreen()),
          ),
          if (app.plan.isEmpty) emptyPlan(context) else habitList(context, day, editable: !future),
          const SizedBox(height: 20),
          cravingCard(context),
        ],
      ),
    );
  }

  Widget _dayChip(DateTime d) {
    final selected = d == day, future = d.isAfter(today());
    const letters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final radius = BorderRadius.circular(16);
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: longDate(d),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: selected ? G.primary : null,
          color: selected ? null : Colors.white,
          borderRadius: radius,
          boxShadow: selected ? S.colored(C.green) : S.soft,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: () => setState(() => day = d),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    letters[d.weekday - 1],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? const Color(0xCCFFFFFF) : C.faint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFeatures: tabular,
                      color: selected
                          ? Colors.white
                          : future
                          ? C.faint
                          : C.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: app.activeDay(d)
                          ? (selected ? Colors.white : C.green)
                          : (selected ? const Color(0x66FFFFFF) : C.line),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: DateTime(today().year - 1),
      lastDate: DateTime(today().year + 1, 12, 31),
      helpText: 'Elige un día',
      cancelText: 'Cancelar',
      confirmText: 'Ver',
    );
    if (picked != null) setState(() => day = DateTime(picked.year, picked.month, picked.day));
  }
}
