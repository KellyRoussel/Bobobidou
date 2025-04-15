import 'dart:convert';
import 'package:bobobidou/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';



class AuthService {
  // Remplacez par l'URL de votre backend
  static const String _baseUrl = 'https://kellyroussel-backend.onrender.com';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

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
    await prefs.remove(_userKey);
  }

  // Démarrer le flux d'authentification Google
  Future<bool> initiateGoogleAuth(BuildContext context) async {
    try {
      // 1. Obtenir l'URL d'authentification du backend
      final response = await http.get(Uri.parse('$_baseUrl/login/google'));

      if (response.statusCode != 200) {
        print(Uri.parse('$_baseUrl/login/google'));
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
        Uri.parse('$_baseUrl/auth/exchange?code=$code'),
      );
      
      if (tokenResponse.statusCode != 200) {
        throw Exception('Failed to exchange code for token');
      }
      
      final tokenData = jsonDecode(tokenResponse.body);
      final accessToken = tokenData['access_token'];

      final user = User.fromJson(tokenData['user']);

      
      // 5. Enregistrer le token et l'utilisateur dans le stockage local
      await saveToken(accessToken);
      await saveUser(user);

      
      return true;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }
}