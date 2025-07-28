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
      // Manejar errores específicos de Firebase Auth
      String errorMessage = 'Error al registrar usuario';
      
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'El correo electrónico ya está en uso';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'La contraseña es muy débil';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Correo electrónico inválido';
      } else if (e.toString().contains('PigeonUserDetails')) {
        // Ignorar errores de PigeonUserDetails ya que el registro fue exitoso
        print('✅ Registro exitoso a pesar del error PigeonUserDetails');
        errorMessage = ''; // No mostrar error al usuario
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      if (errorMessage.isNotEmpty) {
        _setError(errorMessage);
      }
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
      String errorMessage = 'Error al iniciar sesión';
      
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'Usuario no encontrado';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Contraseña incorrecta';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Correo electrónico inválido';
      } else if (e.toString().contains('PigeonUserDetails')) {
        // Ignorar errores de PigeonUserDetails ya que el login fue exitoso
        print('✅ Login exitoso a pesar del error PigeonUserDetails');
        errorMessage = ''; // No mostrar error al usuario
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      if (errorMessage.isNotEmpty) {
        _setError(errorMessage);
      }
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