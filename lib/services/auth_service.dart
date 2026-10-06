import 'dart:convert';
import 'package:bobobidou/config/app_config.dart';
import 'package:bobobidou/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


/// Levée quand la session ne peut plus être renouvelée : l'utilisateur doit se reconnecter.
class SessionExpiredException implements Exception {
  @override
  String toString() => 'SessionExpiredException: please login again';
}

class AuthService {
  static String get _baseUrl => AppConfig.backendUrl;
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // Marge avant expiration en dessous de laquelle on renouvelle le token
  static const Duration _expiryMargin = Duration(minutes: 2);

  // Un seul renouvellement à la fois : le backend invalide l'ancien refresh token
  static Future<String?>? _refreshInFlight;

  // Pour vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Récupérer le token depuis le stockage local
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Enregistrer le token dans le stockage local
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Lire la date d'expiration (claim "exp") d'un JWT sans vérifier la signature
  static DateTime? _tokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000, isUtc: true);
    } catch (_) {
      return null;
    }
  }

  static bool _isExpired(String token) {
    final expiry = _tokenExpiry(token);
    if (expiry == null) return true;
    return DateTime.now().toUtc().isAfter(expiry.subtract(_expiryMargin));
  }

  /// Renvoie un access token valide, en le renouvelant si besoin.
  /// Renvoie null si la session est perdue (les tokens locaux sont alors effacés).
  Future<String?> getValidToken({bool forceRefresh = false}) async {
    final token = await getToken();
    if (token == null) return null;
    if (!forceRefresh && !_isExpired(token)) return token;
    return refreshAccessToken();
  }

  /// Échange le refresh token contre une nouvelle paire de tokens.
  Future<String?> refreshAccessToken() {
    return _refreshInFlight ??= _doRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<String?> _doRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      await logout();
      return null;
    }

    final http.Response response;
    try {
      response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh-token'),
        headers: {'X-Refresh-Token': refreshToken},
      );
    } catch (e) {
      // Erreur réseau : on garde la session, l'appelant affichera une erreur
      debugPrint('Refresh token network error: $e');
      rethrow;
    }

    if (response.statusCode == 401 || response.statusCode == 404) {
      await logout();
      return null;
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to refresh token (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    final String accessToken = data['access_token'];
    await saveToken(accessToken);
    if (data['refresh_token'] != null) {
      await saveRefreshToken(data['refresh_token']);
    }
    return accessToken;
  }

  // Enregistrer les données utilisateur dans le stockage local
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Récupérer l'utilisateur depuis le stockage local
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Déconnecter l'utilisateur
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
  }

  // Démarrer le flux d'authentification Google
  Future<bool> initiateGoogleAuth(BuildContext context) async {
    try {
      // 1. Obtenir l'URL d'authentification du backend
      final response = await http.get(Uri.parse('$_baseUrl/login/google/bobobidou'));

      if (response.statusCode != 200) {
        throw Exception('Failed to get authentication URL');
      }
      
      final data = jsonDecode(response.body);
      final authUrl = data['authorization_url'];
      // 2. Ouvrir l'URL dans un navigateur et attendre le callback
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: 'bobobidou', // Votre schéma d'URL enregistré pour le callback
      );
      // 3. Extraire le code d'autorisation de l'URL de callback
      final code = Uri.parse(result).queryParameters['code'];

      
      if (code == null) {
        throw Exception('Authorization code not found');
      }

      // 4. Échanger le code contre un token
      final tokenResponse = await http.get(
        Uri.parse('$_baseUrl/auth/exchange/bobobidou?code=$code&service=GOOGLE'),
      );
      
      if (tokenResponse.statusCode != 200) {
        debugPrint('Exchange response body: ${tokenResponse.body}');
        throw Exception('Failed to exchange code for token (${tokenResponse.statusCode})');
      }
      
      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      final user = User.fromJson(tokenData['user']);

      
      // 5. Enregistrer le token et l'utilisateur dans le stockage local
      await saveToken(accessToken);
      if (tokenData['refresh_token'] != null) {
        await saveRefreshToken(tokenData['refresh_token']);
      }
      await saveUser(user);

      
      return true;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }
}