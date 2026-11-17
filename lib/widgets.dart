import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons_500.dart';

import 'data.dart';
import 'state.dart';
import 'theme.dart';

/// Hora sin puntos, por ejemplo 4:30 pm
String clock(int h, int m) => '${h % 12 == 0 ? 12 : h % 12}:${m.toString().padLeft(2, '0')} ${h < 12 ? 'am' : 'pm'}';

Color soft(Color c) => Color.alphaBlend(c.withValues(alpha: .12), Colors.white);

Future<T?> push<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

// ---------- Botones ----------

enum Tone { primary, secondary, accent, outline, light, danger, dangerSolid }

class Btn extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Future<void> Function()? onPressed;
  final Tone tone;
  final double height;
  const Btn(this.label, {super.key, this.icon, this.onPressed, this.tone = Tone.primary, this.height = 56});

  @override
  State<Btn> createState() => _BtnState();
}

class _BtnState extends State<Btn> {
  bool busy = false, down = false;

  Future<void> run() async {
    if (busy || widget.onPressed == null) return;
    setState(() => busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    var (Gradient? gradient, Color bg, Color fg, Color? border, List<BoxShadow> shadow) = switch (widget.tone) {
      Tone.primary => (G.primary, C.green, Colors.white, null, S.colored(C.green)),
      Tone.secondary => (G.secondary, C.turq, Colors.white, null, S.colored(C.turq)),
      Tone.accent => (G.accent, C.orange, Colors.white, null, S.colored(C.orange)),
      Tone.dangerSolid => (G.of(C.red), C.red, Colors.white, null, S.colored(C.red)),
      Tone.outline => (null, const Color(0xFFF0FDF4), C.greenDeep, const Color(0xFF86EFAC), const <BoxShadow>[]),
      Tone.light => (null, Colors.white, C.greenDeep, null, S.raised),
      Tone.danger => (null, const Color(0xFFFEF2F2), C.red, const Color(0xFFFCA5A5), const <BoxShadow>[]),
    };
    if (!enabled) (gradient, bg, fg, border, shadow) = (null, C.line, C.faint, null, const []);
    final radius = BorderRadius.circular(16);
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      child: AnimatedScale(
        scale: down ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(borderRadius: radius, boxShadow: shadow),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
                color: gradient == null ? bg : null,
                borderRadius: radius,
                border: border == null ? null : Border.all(color: border, width: 1.5),
              ),
              child: InkWell(
                borderRadius: radius,
                onTap: enabled ? run : null,
                onTapDown: enabled ? (_) => setState(() => down = true) : null,
                onTapUp: (_) => setState(() => down = false),
                onTapCancel: () => setState(() => down = false),
                splashColor: fg.withValues(alpha: .14),
                highlightColor: fg.withValues(alpha: .06),
                child: Center(
                  // sin spinner mientras hay un diálogo encima esperando respuesta
                  child: busy && (ModalRoute.of(context)?.isCurrent ?? true)
                      ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: fg))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                widget.label,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: fg, fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (widget.icon != null) ...[
                              const SizedBox(width: 10),
                              Icon(widget.icon, size: 20, color: fg),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón fijo abajo, con un velo del fondo para separar del contenido
class BottomAction extends StatelessWidget {
  final Widget child;
  const BottomAction(this.child, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: C.bg,
      boxShadow: [BoxShadow(color: Color(0x0A111827), blurRadius: 16, offset: Offset(0, -6))],
    ),
    padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.paddingOf(context).bottom),
    child: child,
  );
}

// ---------- Superficies ----------

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Color? borderColor;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color = C.surface,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Container(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: color == C.surface ? S.soft : null),
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool filled;
  const IconTile(this.icon, this.color, {super.key, this.size = 48, this.filled = false});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: filled ? null : soft(color),
      gradient: filled ? G.of(color) : null,
      borderRadius: BorderRadius.circular(size * .3),
      boxShadow: filled ? S.colored(color) : null,
    ),
    child: Icon(icon, color: filled ? Colors.white : color, size: size * .48),
  );
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final Color? background;
  const Pill(this.text, {super.key, this.color = C.green, this.icon, this.background});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(color: background ?? soft(color), borderRadius: BorderRadius.circular(99)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 15, color: color), const SizedBox(width: 5)],
        Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13.5, fontFeatures: tabular),
        ),
      ],
    ),
  );
}

/// Aviso con color según el tipo: info, advertencia, consejo o peligro
enum Note { info, warn, tip, danger }

class Callout extends StatelessWidget {
  final Note note;
  final IconData icon;
  final String? heading;
  final String text;
  final Widget? child;
  const Callout(this.text, {super.key, this.note = Note.info, required this.icon, this.heading, this.child});

  @override
  Widget build(BuildContext context) {
    final (Color c, Color bg, Color edge, Color deep) = switch (note) {
      Note.info => (C.turq, const Color(0xFFECFEFF), const Color(0xFFA5F3FC), const Color(0xFF155E75)),
      Note.warn => (C.amber, const Color(0xFFFFFBEB), const Color(0xFFFCD34D), const Color(0xFF92400E)),
      Note.tip => (C.green, const Color(0xFFF0FDF4), const Color(0xFFBBF7D0), const Color(0xFF166534)),
      Note.danger => (C.red, const Color(0xFFFEF2F2), const Color(0xFFFECACA), const Color(0xFF991B1B)),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: edge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(icon, c, size: 36, filled: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (heading != null) ...[
                      Text(
                        heading!,
                        style: TextStyle(color: deep, fontWeight: FontWeight.w700, fontSize: 15.5),
                      ),
                      const SizedBox(height: 2),
                    ] else
                      const SizedBox(height: 7),
                    Text(text, style: TextStyle(color: deep, fontSize: 15, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          ?child,
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final double size;
  final Color ring;
  const Avatar({super.key, this.size = 52, this.ring = Colors.white});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: ring, shape: BoxShape.circle, boxShadow: S.soft),
      child: CircleAvatar(
        radius: size / 2 - 3,
        backgroundColor: C.greenSoft,
        foregroundImage: app.avatar,
        child: Text(
          app.firstName.isEmpty ? '?' : app.firstName[0].toUpperCase(),
          style: title(size * .4, color: C.green),
        ),
      ),
    ),
  );
}

/// Botón redondo blanco con sombra, para volver o acciones de cabecera
class RoundBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;
  const RoundBtn(this.icon, {super.key, required this.tooltip, this.onPressed, this.color = C.ink});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: S.soft),
    child: IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: color, fixedSize: const Size(48, 48)),
      icon: Icon(icon, size: 22),
    ),
  );
}

class BackBtn extends StatelessWidget {
  const BackBtn({super.key});
  @override
  Widget build(BuildContext context) =>
      RoundBtn(LucideIcons500.chevronLeft, tooltip: 'Volver', onPressed: () => Navigator.of(context).maybePop());
}

/// Encabezado de pantalla secundaria: volver, título y bajada
class Header extends StatelessWidget {
  final String text;
  final String? sub;
  final Widget? trailing;
  const Header(this.text, {super.key, this.sub, this.trailing});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const BackBtn(), const Spacer(), ?trailing]),
        const SizedBox(height: 18),
        Text(text, style: title(32)),
        if (sub != null) ...[
          const SizedBox(height: 6),
          Text(sub!, style: const TextStyle(color: C.muted, fontSize: 16, height: 1.35)),
        ],
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.text, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 26, 0, 10),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
        ),
        if (action != null)
          onAction == null
              ? Text(
                  action!,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: C.green),
                )
              : TextButton.icon(
                  onPressed: onAction,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(LucideIcons500.chevronRight, size: 18),
                  label: Text(action!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
      ],
    ),
  );
}

class Label extends StatelessWidget {
  final String text;
  const Label(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5, color: C.body),
    ),
  );
}

/// Anillo de progreso con contenido al centro
class Ring extends StatelessWidget {
  final double value;
  final double size, stroke;
  final Color color, track;
  final Widget child;
  const Ring({
    super.key,
    required this.value,
    required this.child,
    this.size = 96,
    this.stroke = 10,
    this.color = C.green,
    this.track = C.line,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => SizedBox.expand(
            child: CircularProgressIndicator(
              value: v,
              strokeWidth: stroke,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: track,
            ),
          ),
        ),
        child,
      ],
    ),
  );
}

/// Casilla cuadrada del Figma: verde con check al marcar
class HabitCheck extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  const HabitCheck({super.key, required this.value, required this.label, this.onChanged});
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    checked: value,
    enabled: onChanged != null,
    label: label,
    child: InkResponse(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      radius: 26,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: value ? G.primary : null,
              color: value ? null : (onChanged == null ? C.field : Colors.white),
              borderRadius: BorderRadius.circular(9),
              border: value ? null : Border.all(color: const Color(0xFFD1D5DB), width: 2),
              boxShadow: value ? S.colored(C.green) : null,
            ),
            child: value ? const Icon(LucideIcons500.check, color: Colors.white, size: 18) : null,
          ),
        ),
      ),
    ),
  );
}

/// Fila de hábito: la casilla marca, el resto abre el detalle
class HabitRow extends StatelessWidget {
  final String id;
  final DateTime day;
  final VoidCallback? onOpen;
  final bool editable;
  const HabitRow(this.id, this.day, {super.key, this.onOpen, this.editable = true});

  @override
  Widget build(BuildContext context) {
    final h = habitById(id);
    final done = app.done(id, day);
    final n = app.count(id, day), t = app.target(id);
    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 10, 14, 10),
        child: Row(
          children: [
            HabitCheck(
              value: done,
              label: done ? 'Desmarcar ${h.title}' : 'Marcar ${h.title}',
              onChanged: editable ? (v) => _toggle(context, v) : null,
            ),
            const SizedBox(width: 4),
            IconTile(h.icon, h.color, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.title,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: done ? C.faint : C.ink,
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: C.faint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(app.goal(id), style: const TextStyle(color: C.muted, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            done
                ? const Pill('Hecho', icon: LucideIcons500.check)
                : h.kind == Kind.check
                ? Pill(app.time(h), color: C.muted, icon: LucideIcons500.clock, background: C.field)
                : Pill('$n de $t', color: h.color),
          ],
        ),
      ),
    );
  }

  void _toggle(BuildContext context, bool value) {
    if (value && habitById(id).kind == Kind.meals) return onOpen?.call();
    final before = app.doneCount(day);
    app.setDone(id, day, value);
    final after = app.doneCount(day);
    if (value && after == app.plan.length && before < after) {
      celebrate(context);
    } else if (value) {
      toast('${habitById(id).title} listo, vas $after de ${app.plan.length}');
    }
  }
}

// ---------- Ventanas ----------

Future<void> celebrate(BuildContext context) => showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    icon: const Center(child: IconTile(LucideIcons500.sparkles, C.green, size: 72, filled: true)),
    title: Text('Completaste tu plan de hoy', style: title(24), textAlign: TextAlign.center),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Cada paso pequeño suma, mañana sigues desde aquí',
          textAlign: TextAlign.center,
          style: const TextStyle(color: C.muted, fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: 14),
        Pill(
          app.streak() == 1 ? 'Racha de 1 día' : 'Racha de ${app.streak()} días',
          color: C.orange,
          icon: LucideIcons500.flame,
        ),
      ],
    ),
    actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    actions: [Btn('Seguir', onPressed: () async => Navigator.pop(ctx))],
  ),
);

/// Confirmación que siempre se puede cerrar con sus botones
Future<bool> confirm(
  BuildContext context, {
  required String heading,
  required String body,
  required String ok,
  bool danger = false,
  IconData? icon,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: icon == null ? null : Center(child: IconTile(icon, danger ? C.red : C.green, size: 60, filled: true)),
      title: Text(heading, style: title(23), textAlign: TextAlign.center),
      content: Text(
        body,
        textAlign: TextAlign.center,
        style: const TextStyle(color: C.muted, fontSize: 16, height: 1.4),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: Btn('Cancelar', tone: Tone.outline, height: 52, onPressed: () async => Navigator.pop(ctx, false)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Btn(
                ok,
                tone: danger ? Tone.dangerSolid : Tone.primary,
                height: 52,
                onPressed: () async => Navigator.pop(ctx, true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Hoja inferior para elegir una opción de una lista
Future<String?> pickOne(BuildContext context, String heading, Map<String, String> options, String? current) {
  FocusManager.instance.primaryFocus?.unfocus();
  return showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(heading, style: title(22)),
          ),
          for (final e in options.entries)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(e.value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
              trailing: e.key == current ? const Icon(LucideIcons500.circleCheck, color: C.green) : null,
              onTap: () => Navigator.pop(ctx, e.key),
            ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
