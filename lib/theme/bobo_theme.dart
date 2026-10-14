import 'package:flutter/material.dart';

import 'bobo_tokens.dart';

/// An accent the user can pick in the settings. Only the accent changes:
/// the peach background, the neutrals and the meal/pain colors stay the
/// same so the app keeps its identity whatever the choice.
enum BoboAccent {
  bobobidou(
    labelKey: 'logo_theme',
    fill: BoboColors.corail,
    deep: BoboColors.corailProfond,
    tint: BoboColors.corailTendre,
  ),
  violet(
    labelKey: 'purple_theme',
    fill: Color(0xFF6750A4),
    deep: Color(0xFF6750A4),
    tint: Color(0xFFEADDFF),
  ),
  vert(
    labelKey: 'green_theme',
    fill: Color(0xFF2E7D32),
    deep: Color(0xFF2E7D32),
    tint: Color(0xFFDCEFD8),
  ),
  bleu(
    labelKey: 'blue_theme',
    fill: Color(0xFF1565C0),
    deep: Color(0xFF1565C0),
    tint: Color(0xFFD9E7FA),
  );

  const BoboAccent({
    required this.labelKey,
    required this.fill,
    required this.deep,
    required this.tint,
  });

  /// Translation key of the accent's name.
  final String labelKey;
  /// Filled surfaces: buttons, FAB, selected chips.
  final Color fill;
  /// Text and icons in the accent color on light grounds.
  final Color deep;
  /// Light containers: navigation indicator, chips, selected rows.
  final Color tint;
}

class BoboTheme {
  BoboTheme._();

  static ThemeData build(BoboAccent accent) {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: accent.fill,
      onPrimary: Colors.white,
      primaryContainer: accent.tint,
      onPrimaryContainer: accent.deep,
      secondary: BoboColors.lagon,
      onSecondary: Colors.white,
      secondaryContainer: BoboColors.lagonTendre,
      onSecondaryContainer: BoboColors.cacao,
      tertiary: BoboColors.prune,
      onTertiary: Colors.white,
      tertiaryContainer: BoboColors.pruneTendre,
      onTertiaryContainer: BoboColors.prune,
      error: BoboColors.erreur,
      onError: Colors.white,
      surface: BoboColors.creme,
      onSurface: BoboColors.cacao,
      onSurfaceVariant: BoboColors.cacaoDoux,
      surfaceContainerLowest: BoboColors.creme,
      surfaceContainerLow: BoboColors.creme,
      surfaceContainer: BoboColors.creme,
      surfaceContainerHigh: BoboColors.creme,
      surfaceContainerHighest: BoboColors.peche,
      outline: BoboColors.contour,
      outlineVariant: BoboColors.ligne,
      surfaceTint: Colors.transparent,
      shadow: BoboColors.cacao,
      inverseSurface: BoboColors.cacao,
      onInverseSurface: BoboColors.peche,
    );

    final textTheme = _textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: accent.fill,
      scaffoldBackgroundColor: BoboColors.peche,
      fontFamily: BoboFonts.body,
      textTheme: textTheme,
      hintColor: BoboColors.cacaoDoux,
      dividerColor: BoboColors.ligne,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: BoboColors.peche,
        foregroundColor: BoboColors.cacao,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BoboColors.creme,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.tint,
        height: 72,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? accent.deep
                : BoboColors.cacaoDoux,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium!.copyWith(
            color: states.contains(WidgetState.selected)
                ? accent.deep
                : BoboColors.cacaoDoux,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: _filledStyle(accent, textTheme)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _filledStyle(accent, textTheme)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent.deep,
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          side: const BorderSide(color: BoboColors.ligne, width: 1.5),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent.deep,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent.fill,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BoboColors.creme,
        hintStyle: textTheme.bodyLarge!.copyWith(color: BoboColors.cacaoDoux),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BoboSpace.lg,
          vertical: BoboSpace.md,
        ),
        border: const OutlineInputBorder(
          borderRadius: BoboRadius.mdAll,
          borderSide: BorderSide(color: BoboColors.ligne, width: 1.5),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BoboRadius.mdAll,
          borderSide: BorderSide(color: BoboColors.ligne, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BoboRadius.mdAll,
          borderSide: BorderSide(color: accent.fill, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accent.tint,
        labelStyle: textTheme.labelLarge!.copyWith(color: BoboColors.cacao),
        deleteIconColor: accent.deep,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: BoboSpace.sm),
      ),
      cardTheme: const CardThemeData(
        color: BoboColors.creme,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BoboRadius.lgAll),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: accent.deep,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: BoboSpace.lg),
      ),
      dividerTheme: const DividerThemeData(
        color: BoboColors.ligne,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: BoboColors.cacao,
        contentTextStyle: textTheme.bodyLarge!.copyWith(color: BoboColors.peche),
        shape: const RoundedRectangleBorder(borderRadius: BoboRadius.mdAll),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BoboColors.peche,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: BoboColors.contour,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(BoboRadius.lg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: BoboColors.creme,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BoboRadius.lgAll),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: BoboColors.creme,
          foregroundColor: BoboColors.cacao,
          selectedBackgroundColor: accent.tint,
          selectedForegroundColor: accent.deep,
          side: const BorderSide(color: BoboColors.ligne, width: 1.5),
          textStyle: textTheme.labelLarge,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent.fill),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: BoboColors.creme,
        surfaceTintColor: Colors.transparent,
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: BoboColors.creme,
      ),
    );
  }

  static ButtonStyle _filledStyle(BoboAccent accent, TextTheme textTheme) {
    return FilledButton.styleFrom(
      backgroundColor: accent.fill,
      foregroundColor: Colors.white,
      minimumSize: const Size(64, 52),
      shape: const StadiumBorder(),
      elevation: 0,
      textStyle: textTheme.labelLarge!.copyWith(fontSize: 16),
    );
  }

  static TextTheme _textTheme() {
    const ink = BoboColors.cacao;
    const muted = BoboColors.cacaoDoux;
    TextStyle display(double size, double height) => TextStyle(
          fontFamily: BoboFonts.display,
          fontWeight: FontWeight.w600,
          fontSize: size,
          height: height / size,
          color: ink,
        );
    TextStyle body(double size, double height, FontWeight weight,
            {Color color = ink, double letterSpacing = 0}) =>
        TextStyle(
          fontFamily: BoboFonts.body,
          fontWeight: weight,
          fontSize: size,
          height: height / size,
          color: color,
          letterSpacing: letterSpacing,
        );

    return TextTheme(
      displaySmall: display(36, 42),
      headlineMedium: display(30, 36),
      headlineSmall: display(24, 30),
      titleLarge: display(20, 26),
      titleMedium: body(16, 22, FontWeight.w700),
      titleSmall: body(14, 20, FontWeight.w700),
      bodyLarge: body(16, 24, FontWeight.w400),
      bodyMedium: body(14, 20, FontWeight.w400, color: muted),
      bodySmall: body(12, 16, FontWeight.w600, color: muted, letterSpacing: 0.2),
      labelLarge: body(15, 20, FontWeight.w800),
      labelMedium: body(12, 16, FontWeight.w700),
      labelSmall: body(11, 14, FontWeight.w800, color: muted, letterSpacing: 0.8),
    );
  }
}
