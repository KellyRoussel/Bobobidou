import 'package:flutter/material.dart';

/// Bobobidou design tokens.
///
/// Mirrors the "Bobobidou" design system (colors, type, spacing, radius,
/// shadow). Widgets should read these tokens instead of hard-coding values,
/// so the app and the communication material stay in sync.
class BoboColors {
  BoboColors._();

  // Brand — taken from the logo
  /// Coral, the default brand color (logo swirl). Fills, primary actions, meals.
  static const corail = Color(0xFFE07A7A);
  /// Deep coral for text, icons and selected states on light grounds.
  static const corailProfond = Color(0xFFA13F47);
  /// Coral tint: meal chips, meal icon backgrounds, selected containers.
  static const corailTendre = Color(0xFFF9DAD6);

  /// Peach, the app background (kept from the original theme).
  static const peche = Color(0xFFFFF0E5);
  /// Splash peach (logo background): headers, hero areas.
  static const pecheSplash = Color(0xFFFBD1B9);

  /// Lagoon blue (logo wave). Secondary accent, "low" severity.
  static const lagon = Color(0xFF3A97B0);
  /// Lagoon tint.
  static const lagonTendre = Color(0xFFDDEFF3);

  /// Plum violet (logo tail). Pain episodes.
  static const prune = Color(0xFF6B4BC4);
  /// Plum tint: pain icon backgrounds.
  static const pruneTendre = Color(0xFFECE6FA);

  /// Citrus yellow (fruits around the logo). Highlights, "moderate" severity.
  static const soleil = Color(0xFFF2B33D);
  static const soleilTendre = Color(0xFFFDF0D3);

  // Neutrals — warm, biased toward the peach background
  /// Main text color.
  static const cacao = Color(0xFF3D2B2B);
  /// Secondary text, captions, placeholders.
  static const cacaoDoux = Color(0xFF7A6260);
  /// Cards, sheets and inputs.
  static const creme = Color(0xFFFFFFFF);
  /// Hairlines and input borders.
  static const ligne = Color(0xFFF0DDD3);
  /// Stronger outline: drag handles, unselected radio rings.
  static const contour = Color(0xFFD9BFB3);

  // Feedback
  static const succes = Color(0xFF2E7D5B);
  static const erreur = Color(0xFFB3261E);

  /// Entry type colors, used everywhere a meal or a pain episode is shown
  /// (journal, timeline, charts) so users learn them once.
  static const repas = corail;
  static const repasTendre = corailTendre;
  static const douleur = prune;
  static const douleurTendre = pruneTendre;
}

/// 4-pt spacing scale.
class BoboSpace {
  BoboSpace._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Side gutter of every page.
  static const double page = 20;
}

/// Corner radii: soft and round, like the logo.
class BoboRadius {
  BoboRadius._();

  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
}

class BoboShadows {
  BoboShadows._();

  /// The only elevation: a soft, warm shadow under cards.
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x143D2B2B), // cacao @ 8%
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
}

class BoboFonts {
  BoboFonts._();

  /// Rounded display face for titles and numbers.
  static const display = 'Fredoka';
  /// Body face for everything else.
  static const body = 'Nunito';
}
