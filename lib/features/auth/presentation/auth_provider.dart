import 'package:flutter/material.dart';
import '../domain/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authRepository);

  bool get isLoading => _isLoading;
  String? get error => _error;
  Stream<bool> get isLoggedIn => _authRepository.isLoggedIn;

  Future<void> registerWithEmail(String email, String password, {required String displayName, int? age, String? location}) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.registerWithEmail(email: email, password: password, displayName: displayName, age: age, location: location);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authRepository.loginWithEmail(email: email, password: password);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
} 