import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'habit.dart';
import 'home.dart' show longDate;
import 'nutrition.dart' show CravingsScreen, cravingTile;

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});
  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  String range = 'Semana';

  DateTime d(int y, int m, int day) => DateTime(y, m, day);

  @override
  Widget build(BuildContext context) {
    final t = today();
    final (from, to) = switch (range) {
      'Mes' => (d(t.year, t.month, 1), d(t.year, t.month + 1, 0)),
      'Año' => (d(t.year, 1, 1), d(t.year, 12, 31)),
      _ => (weekStart(t), d(weekStart(t).year, weekStart(t).month, weekStart(t).day + 6)),
    };
    var active = 0, completed = 0, elapsed = 0;
    for (var x = from; !x.isAfter(to) && !x.isAfter(t); x = d(x.year, x.month, x.day + 1)) {
      elapsed++;
      if (app.activeDay(x)) active++;
      completed += app.doneCount(x);
    }
    final pct = app.percent(from, to);
    final cravings = app.cravings
        .where((c) => !c.at.isBefore(from) && c.at.isBefore(d(to.year, to.month, to.day + 1)))
        .toList();

    final List<(String, double, bool)> bars = switch (range) {
      'Mes' => [
        for (var x = from; !x.isAfter(to); x = d(x.year, x.month, x.day + 1)) ('${x.day}', _dayValue(x), x == t),
      ],
      'Año' => [
        for (var m = 1; m <= 12; m++)
          (
            DateFormat('MMM', 'es').format(d(t.year, m, 1)).substring(0, 1).toUpperCase(),
            app.percent(d(t.year, m, 1), d(t.year, m + 1, 0)) / 100,
            m == t.month,
          ),
      ],
      _ => [
        for (var i = 0; i < 7; i++)
          (
            const ['L', 'M', 'X', 'J', 'V', 'S', 'D'][i],
            _dayValue(d(from.year, from.month, from.day + i)),
            d(from.year, from.month, from.day + i) == t,
          ),
      ],
    };

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text('Mi progreso', style: title(32)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Semana', label: Text('Semana')),
                ButtonSegment(value: 'Mes', label: Text('Mes')),
                ButtonSegment(value: 'Año', label: Text('Año')),
              ],
              selected: {range},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => range = s.first),
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.white,
                selectedBackgroundColor: C.ink,
                selectedForegroundColor: Colors.white,
                side: BorderSide.none,
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: G.hero,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: S.colored(C.teal),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0x2EFFFFFF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons500.flame, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 14),
                      Text(active == 1 ? '1 día' : '$active días', style: title(28, color: Colors.white)),
                      Text('activos de $elapsed', style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: S.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const IconTile(LucideIcons500.circleCheck, C.green, size: 38),
                          const Spacer(),
                          Pill('$pct %', color: C.green),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('$completed', style: title(28)),
                      Text(
                        completed == 1 ? 'hábito completado' : 'hábitos completados',
                        style: const TextStyle(color: C.muted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SectionTitle(
            range == 'Semana'
                ? 'Esta semana'
                : range == 'Mes'
                ? 'Este mes'
                : 'Este año',
          ),
          Panel(child: SizedBox(height: 170, child: BarChart(bars))),
          SectionTitle('Hoy', action: '${app.doneCount(t)} de ${app.plan.length}'),
          Panel(
            child: app.plan.isEmpty
                ? const Text('Aún no tienes hábitos activos', style: TextStyle(color: C.muted))
                : Wrap(spacing: 14, runSpacing: 14, children: [for (final id in app.plan) _todayHabit(context, id)]),
          ),
          SectionTitle(
            'Antojos registrados',
            action: 'Registrar',
            onAction: () => push(context, const CravingsScreen()),
          ),
          if (cravings.isEmpty)
            Text(
              'Sin registros ${range == 'Semana'
                  ? 'esta semana'
                  : range == 'Mes'
                  ? 'este mes'
                  : 'este año'}',
              style: const TextStyle(color: C.muted, fontSize: 15.5),
            )
          else
            for (final c in cravings.take(3)) cravingTile(c),
          const SectionTitle('Historial'),
          Panel(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < 7; i++)
                  ListTile(
                    title: Text(
                      i == 0
                          ? 'Hoy'
                          : i == 1
                          ? 'Ayer'
                          : longDate(t.subtract(Duration(days: i))),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      '${app.doneCount(t.subtract(Duration(days: i)))} de ${app.plan.length}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontFeatures: tabular),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _dayValue(DateTime x) => app.plan.isEmpty || x.isAfter(today()) ? 0 : app.doneCount(x) / app.plan.length;

  Widget _todayHabit(BuildContext context, String id) {
    final h = habitById(id), done = app.done(id, today());
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => push(context, HabitScreen(id, today())),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: done ? h.color : soft(h.color), shape: BoxShape.circle),
              child: Icon(h.icon, color: done ? Colors.white : h.color),
            ),
            const SizedBox(height: 6),
            Text(
              shortNames[id]!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: C.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class BarChart extends StatelessWidget {
  final List<(String, double, bool)> bars;
  const BarChart(this.bars, {super.key});
  @override
  Widget build(BuildContext context) {
    final dense = bars.length > 12;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (label, v, current) in bars)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: dense ? 1 : 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: v == 0 ? .04 : v,
                        child: Container(
                          decoration: BoxDecoration(
                            color: v == 0 ? C.field : null,
                            gradient: v == 0
                                ? null
                                : LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: current
                                        ? const [Color(0xFF22C55E), C.greenDeep]
                                        : const [Color(0xFF86EFAC), Color(0xFF4ADE80)],
                                  ),
                            borderRadius: BorderRadius.circular(dense ? 3 : 10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dense && int.parse(label) % 5 != 1 ? '' : label,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: current ? C.green : C.muted,
                      fontWeight: current ? FontWeight.w700 : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
