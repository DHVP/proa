import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

class HabitScreen extends StatelessWidget {
  final String id;
  final DateTime day;
  const HabitScreen(this.id, this.day, {super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: app, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    final h = habitById(id);
    final done = app.done(id, day), n = app.count(id, day), t = app.target(id);
    final future = day.isAfter(today());
    final week = weekStart(today());
    final weekDone = [for (var i = 0; i < 7; i++) app.done(id, DateTime(week.year, week.month, week.day + i))];
    final weekCount = weekDone.where((x) => x).length;
    final streak = app.streak(id);
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                          child: Image.asset(
                            'assets/images/${h.image}.jpg',
                            height: w * .62,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: -44,
                          child: Panel(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                IconTile(h.icon, h.color, size: 54, filled: true),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(h.title, style: title(22), maxLines: 2),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Meta: ${lower(app.goal(id))}',
                                        style: const TextStyle(color: C.muted, fontSize: 14.5),
                                      ),
                                    ],
                                  ),
                                ),
                                done
                                    ? const Pill('Hecho', icon: LucideIcons500.check)
                                    : const Pill('Pendiente', color: C.orange, background: C.orangeSoft),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 62, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              _stat(h.kind == Kind.check ? (done ? 'Sí' : 'No') : '$n/$t', 'Hoy', h.color),
                              const SizedBox(width: 10),
                              _stat('$streak', streak == 1 ? 'Día seguido' : 'Días seguidos', C.orange),
                              const SizedBox(width: 10),
                              _stat('${(weekCount * 100 / 7).round()} %', 'Esta semana', C.green),
                            ],
                          ),
                          if (h.kind != Kind.check) ...[
                            const SizedBox(height: 14),
                            Panel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Registro del día',
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5),
                                        ),
                                      ),
                                      Text(
                                        id == 'agua' ? '${liters(n)} L de ${liters(t)} L' : '$n de $t',
                                        style: TextStyle(color: h.color, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _tracker(h, n, t, future),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Text(h.description, style: const TextStyle(fontSize: 17, height: 1.5, color: C.body)),
                          const SizedBox(height: 18),
                          Panel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Esta semana',
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5),
                                      ),
                                    ),
                                    Pill('$weekCount de 7 días', color: C.turq),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (var i = 0; i < 7; i++)
                                      _weekDot(i, weekDone[i], DateTime(week.year, week.month, week.day + i)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Callout(h.tip, note: Note.tip, icon: LucideIcons500.lightbulb, heading: 'Consejo práctico'),
                        ],
                      ),
                    ),
                  ],
                ),
                // volver queda fijo aunque se haga scroll
                const Positioned(
                  left: 16,
                  top: 0,
                  child: SafeArea(
                    child: Padding(padding: EdgeInsets.only(top: 8), child: BackBtn()),
                  ),
                ),
              ],
            ),
          ),
          // las comidas se completan registrando cada una, no con un botón
          if (!future && h.kind != Kind.meals)
            BottomAction(
              done
                  ? Btn(
                      'Completado hoy',
                      icon: LucideIcons500.check,
                      tone: Tone.outline,
                      onPressed: () async {
                        if (await confirm(
                          context,
                          heading: '¿Desmarcar este hábito?',
                          body: 'Volverá a quedar pendiente para este día',
                          ok: 'Desmarcar',
                        )) {
                          app.setDone(id, day, false);
                        }
                      },
                    )
                  : Btn(
                      'Marcar como completado',
                      icon: LucideIcons500.check,
                      onPressed: () async {
                        app.setDone(id, day, true);
                        Navigator.of(context).pop();
                        toast('${h.title} listo, vas ${app.doneCount(day)} de ${app.plan.length}');
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: S.soft),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700, fontFeatures: tabular),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: C.muted, fontSize: 12.5)),
        ],
      ),
    ),
  );

  Widget _tracker(HabitDef h, int n, int t, bool future) {
    if (h.kind == Kind.meals) {
      final mask = app.raw(id, day);
      return Row(
        children: [
          for (final (i, m) in meals.indexed) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _cell(
                on: mask & (1 << i) != 0,
                color: h.color,
                label: m,
                icon: LucideIcons500.utensils,
                onTap: future ? null : () => app.setRaw(id, day, mask ^ (1 << i)),
              ),
            ),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < t; i++)
              SizedBox(
                width: 46,
                child: _cell(
                  on: i < n,
                  color: h.color,
                  label: '${i + 1} de $t',
                  icon: h.icon,
                  // tocar la última marcada la quita, tocar otra llena hasta ahí
                  onTap: future ? null : () => app.setRaw(id, day, n == i + 1 ? i : i + 1),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          id == 'agua' ? 'Toca un vaso para sumarlo o quitarlo' : 'Toca una porción para sumarla o quitarla',
          style: const TextStyle(color: C.muted, fontSize: 13.5),
        ),
      ],
    );
  }

  /// Celda del registro: llena con degradado al marcarla
  Widget _cell({
    required bool on,
    required Color color,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final showText = label.length > 6;
    return Semantics(
      container: true,
      button: true,
      checked: on,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: showText ? 78 : 52,
          decoration: BoxDecoration(
            gradient: on ? G.of(color) : null,
            color: on ? null : soft(color),
            borderRadius: BorderRadius.circular(14),
            border: on ? null : Border.all(color: color.withValues(alpha: .25)),
            boxShadow: on ? S.colored(color) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(on ? LucideIcons500.check : icon, color: on ? Colors.white : color, size: 22),
              if (showText) ...[
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(color: on ? Colors.white : color, fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _weekDot(int i, bool done, DateTime d) {
    const letters = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final isToday = d == today();
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: done ? G.primary : null,
            color: done ? null : Colors.white,
            border: done ? null : Border.all(color: isToday ? C.green : C.line, width: isToday ? 2 : 1.5),
          ),
          child: done ? const Icon(LucideIcons500.check, color: Colors.white, size: 18) : null,
        ),
        const SizedBox(height: 6),
        Text(
          letters[i],
          style: TextStyle(
            fontSize: 13,
            color: isToday ? C.green : C.muted,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

String lower(String s) => s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

String liters(int glasses) => NumberFormat.decimalPattern('es').format(glasses * .25);
