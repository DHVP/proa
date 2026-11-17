import 'package:flutter/material.dart';

/// Paleta de la guía de estilos PROA en Figma
class C {
  static const bg = Color(0xFFF4FAF6);
  static const surface = Colors.white;
  static const field = Color(0xFFF3F5F4);
  static const ink = Color(0xFF111827);
  static const body = Color(0xFF374151);
  static const muted = Color(0xFF6B7280);
  static const faint = Color(0xFF9CA3AF);
  static const line = Color(0xFFE5E7EB);

  static const green = Color(0xFF16A34A);
  static const greenDeep = Color(0xFF15803D);
  static const teal = Color(0xFF0F766E);
  static const greenSoft = Color(0xFFDCFCE7);

  static const turq = Color(0xFF0891B2);
  static const turqDeep = Color(0xFF0E7490);
  static const turqSoft = Color(0xFFCFFAFE);

  static const orange = Color(0xFFEA580C);
  static const amber = Color(0xFFF59E0B);
  static const orangeSoft = Color(0xFFFFEDD5);

  static const red = Color(0xFFDC2626);
  static const redSoft = Color(0xFFFEE2E2);
}

/// Degradados de botones y tarjeta héroe
class G {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1DAF55), C.greenDeep],
  );
  static const secondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [C.turq, C.turqDeep],
  );
  static const accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [C.orange, Color(0xFFC2410C)],
  );
  static const hero = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [C.green, C.teal]);

  static LinearGradient of(Color c) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color.lerp(c, Colors.white, .12)!, Color.lerp(c, Colors.black, .12)!],
  );
}

/// Sombras: suave para tarjetas, elevada para lo que flota, de color para botones
class S {
  static const soft = [BoxShadow(color: Color(0x0F111827), blurRadius: 24, offset: Offset(0, 8))];
  static const raised = [BoxShadow(color: Color(0x1A111827), blurRadius: 30, offset: Offset(0, 12))];
  static List<BoxShadow> colored(Color c) => [
    BoxShadow(color: c.withValues(alpha: .32), blurRadius: 18, offset: const Offset(0, 8)),
  ];
}

const display = 'Fraunces';

TextStyle title(double size, {Color color = C.ink}) => TextStyle(
  fontFamily: display,
  fontWeight: FontWeight.w600,
  fontSize: size,
  height: 1.12,
  letterSpacing: -0.4,
  color: color,
);

const tabular = [FontFeature.tabularFigures()];

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Hanken',
    colorScheme: ColorScheme.fromSeed(seedColor: C.green, primary: C.green, surface: C.surface),
    scaffoldBackgroundColor: C.bg,
  );
  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: c, width: w),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: C.ink, displayColor: C.ink),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentTextStyle: const TextStyle(fontFamily: 'Hanken', fontSize: 15, color: Colors.white),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: C.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: C.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: C.faint),
      prefixIconColor: WidgetStateColor.resolveWith((s) => s.contains(WidgetState.focused) ? C.green : C.faint),
      border: border(C.line),
      enabledBorder: border(C.line),
      focusedBorder: border(C.green, 2),
      errorBorder: border(C.red),
      focusedErrorBorder: border(C.red, 2),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.green : C.line),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(color: s.contains(WidgetState.selected) ? C.green : C.faint, size: 24),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: 'Hanken',
          fontSize: 12.5,
          fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? C.green : C.muted,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: C.field,
      selectedColor: C.ink,
      side: BorderSide.none,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      labelStyle: const TextStyle(fontFamily: 'Hanken', fontWeight: FontWeight.w600, color: C.body),
      secondaryLabelStyle: const TextStyle(fontFamily: 'Hanken', fontWeight: FontWeight.w600, color: Colors.white),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: C.field,
        selectedBackgroundColor: Colors.white,
        selectedForegroundColor: C.ink,
        foregroundColor: C.muted,
        side: BorderSide.none,
        textStyle: const TextStyle(fontFamily: 'Hanken', fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    dividerTheme: const DividerThemeData(color: C.line, space: 1, thickness: 1),
    listTileTheme: const ListTileThemeData(iconColor: C.muted),
  );
}
