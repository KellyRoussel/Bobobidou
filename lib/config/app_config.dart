import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get backendUrl => dotenv.env['BACKEND_URL']!;

  /// Privacy policy hosted on GitHub Pages from `docs/privacy/`.
  static String privacyPolicyUrl(String languageCode) {
    const base = 'https://kellyroussel.github.io/Bobobidou/privacy/';
    return languageCode == 'fr' ? base : '${base}en.html';
  }
}
