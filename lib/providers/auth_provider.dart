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
}