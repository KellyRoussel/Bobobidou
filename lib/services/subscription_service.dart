import 'dart:convert';

import 'package:bobobidou/config/app_config.dart';
import 'package:bobobidou/models/subscription_status.dart';
import 'package:bobobidou/services/auth_service.dart';
import 'package:http/http.dart' as http;

/// The subscription as the backend sees it. The purchase itself goes through
/// RevenueCat (Google Play), see SubscriptionProvider.
class SubscriptionService {
  static String get _baseUrl => AppConfig.backendUrl;
  final AuthService _authService = AuthService();

  /// State known from the RevenueCat webhooks, and free photos left.
  Future<SubscriptionStatus> fetchStatus() => _call('GET', '/bobobidou/subscription');

  /// Asks the backend to read the subscription from RevenueCat now: right
  /// after a purchase or a restore, the webhook may not have arrived yet.
  Future<SubscriptionStatus> refreshStatus() => _call('POST', '/bobobidou/subscription/refresh');

  Future<SubscriptionStatus> _call(String method, String path) async {
    final token = await _authService.getValidToken();
    if (token == null) throw SessionExpiredException();

    var response = await _send(method, path, token);
    // Token rejected (expired or revoked): renew it once and retry
    if (response.statusCode == 401) {
      final newToken = await _authService.getValidToken(forceRefresh: true);
      if (newToken == null) throw SessionExpiredException();
      response = await _send(method, path, newToken);
      if (response.statusCode == 401) {
        await _authService.logout();
        throw SessionExpiredException();
      }
    }
    if (response.statusCode != 200) {
      throw Exception('Subscription request failed (${response.statusCode})');
    }
    return SubscriptionStatus.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<http.Response> _send(String method, String path, String token) {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = {'Authorization': 'Bearer $token'};
    return method == 'POST' ? http.post(uri, headers: headers) : http.get(uri, headers: headers);
  }
}
