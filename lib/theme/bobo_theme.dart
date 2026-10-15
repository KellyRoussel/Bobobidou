import 'package:flutter/material.dart';

import 'bobo_tokens.dart';

class BoboTheme {
  BoboTheme._();

  /// The app theme: coral on peach, as in the logo.
  static final ThemeData light = _build();

  static ThemeData _build() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: BoboColors.corail,
      onPrimary: Colors.white,
      primaryContainer: BoboColors.corailTendre,
      onPrimaryContainer: BoboColors.corailProfond,
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
      primaryColor: BoboColors.corail,
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
        indicatorColor: BoboColors.corailTendre,
        height: 72,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? BoboColors.corailProfond
                : BoboColors.cacaoDoux,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium!.copyWith(
            color: states.contains(WidgetState.selected)
                ? BoboColors.corailProfond
                : BoboColors.cacaoDoux,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: _filledStyle(textTheme)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _filledStyle(textTheme)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BoboColors.corailProfond,
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          side: const BorderSide(color: BoboColors.ligne, width: 1.5),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BoboColors.corailProfond,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: BoboColors.corail,
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
          borderSide: BorderSide(color: BoboColors.corail, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: BoboColors.corailTendre,
        labelStyle: textTheme.labelLarge!.copyWith(color: BoboColors.cacao),
        deleteIconColor: BoboColors.corailProfond,
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
        iconColor: BoboColors.corailProfond,
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
          selectedBackgroundColor: BoboColors.corailTendre,
          selectedForegroundColor: BoboColors.corailProfond,
          side: const BorderSide(color: BoboColors.ligne, width: 1.5),
          textStyle: textTheme.labelLarge,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: BoboColors.corail),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: BoboColors.creme,
        surfaceTintColor: Colors.transparent,
      ),
      timePickerTheme: const TimePickerThemeData(
        backgroundColor: BoboColors.creme,
      ),
    );
  }

  static ButtonStyle _filledStyle(TextTheme textTheme) {
    return FilledButton.styleFrom(
      backgroundColor: BoboColors.corail,
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
