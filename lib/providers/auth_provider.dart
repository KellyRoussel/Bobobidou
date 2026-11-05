import 'package:flutter/material.dart';
import 'package:bobobidou/models/user.dart';
import 'package:bobobidou/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = true;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    _isLoading = true;
    notifyListeners();

    _isAuthenticated = await _authService.isAuthenticated();
    if (_isAuthenticated) {
      _user = await _authService.getUser();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Vérifie que la session est encore utilisable (renouvelle le token si besoin).
  /// Met l'état à jour si la session a été perdue.
  Future<bool> ensureValidSession() async {
    if (!_isAuthenticated) return false;
    try {
      final token = await _authService.getValidToken();
      if (token == null) {
        _isAuthenticated = false;
        _user = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Erreur réseau pendant le renouvellement : on garde la session,
      // l'appel suivant affichera l'erreur.
      debugPrint('Session check failed: $e');
    }
    return true;
  }

  /// La session a été refusée par le backend (tokens déjà effacés par AuthService) :
  /// toute l'app repasse en mode déconnecté.
  void sessionExpired() {
    if (!_isAuthenticated) return;
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<bool> login(BuildContext context) async {

    _isLoading = true;
    notifyListeners();

    final success = await _authService.initiateGoogleAuth(context);
    if (success) {
      _isAuthenticated = true;
      _user = await _authService.getUser();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _isAuthenticated = false;
    _user = null;

    _isLoading = false;
    notifyListeners();
  }

  /// Supprime le compte backend. `success` à false en cas d'échec (session conservée) ;
  /// `subscriptionCancelFailed` si l'abonnement n'a pas pu être résilié.
  Future<({bool success, bool subscriptionCancelFailed})> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    ({bool success, bool subscriptionCancelFailed}) result;
    try {
      result = await _authService.deleteAccount();
    } catch (e) {
      debugPrint('Delete account error: $e');
      result = (success: false, subscriptionCancelFailed: false);
    }
    final success = result.success;
    if (success) {
      _isAuthenticated = false;
      _user = null;
    } else {
      // La session a pu être perdue pendant le renouvellement du token
      _isAuthenticated = await _authService.isAuthenticated();
      if (!_isAuthenticated) _user = null;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
