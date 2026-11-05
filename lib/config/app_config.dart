import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get backendUrl => dotenv.env['BACKEND_URL']!;

  /// Public RevenueCat SDK key of the Android app (`goog_...`). Empty: the
  /// store is unavailable (purchases disabled), the rest of the app works.
  static String get revenueCatApiKey => dotenv.env['REVENUECAT_API_KEY'] ?? '';

  /// Google Play page where the user manages (and cancels) their subscriptions.
  static final Uri playSubscriptionsUrl = Uri.parse(
      'https://play.google.com/store/account/subscriptions?package=com.kellyroussel.bobobidou');

  /// Privacy policy hosted on GitHub Pages from `docs/privacy/`.
  static String privacyPolicyUrl(String languageCode) {
    const base = 'https://kellyroussel.github.io/Bobobidou/privacy/';
    return languageCode == 'fr' ? base : '${base}en.html';
  }
}
