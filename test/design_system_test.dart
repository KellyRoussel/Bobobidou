import 'dart:ui';
import 'dart:convert';
import 'dart:io';

import 'package:bobobidou/pages/analysis_page/severity.dart';
import 'package:bobobidou/theme/bobo_theme.dart';
import 'package:bobobidou/theme/bobo_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and French translations have the same keys', () {
    Set<String> keysOf(String lang) =>
        (jsonDecode(File('assets/lang/$lang.json').readAsStringSync()) as Map<String, dynamic>)
            .keys
            .toSet();
    final en = keysOf('en');
    final fr = keysOf('fr');
    expect(en.difference(fr), isEmpty, reason: 'missing in fr.json');
    expect(fr.difference(en), isEmpty, reason: 'missing in en.json');
  });

  test('the theme keeps the Bobobidou colors and fonts', () {
    final theme = BoboTheme.light;
    expect(theme.scaffoldBackgroundColor, BoboColors.peche);
    expect(theme.colorScheme.primary, const Color(0xFFE07A7A));
    expect(theme.textTheme.headlineMedium!.fontFamily, BoboFonts.display);
    expect(theme.textTheme.bodyLarge!.fontFamily, BoboFonts.body);
  });

  test('severity follows the ratio to the most frequent ingredient', () {
    expect(Severity.of(1), Severity.high);
    expect(Severity.of(0.6), Severity.elevated);
    expect(Severity.of(0.5), Severity.moderate);
    expect(Severity.of(0.25), Severity.low);
  });
}
