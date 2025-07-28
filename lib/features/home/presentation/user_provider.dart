import 'package:flutter/foundation.dart';
import '../data/user_repository.dart';
import 'user_model.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _repository;
  
  UserProvider({UserRepository? repository}) 
      : _repository = repository ?? FirebaseUserRepository();

  // Estado
  List<User> _users = [];
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<User> get users => _users;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Métodos CRUD
  Future<void> createUser(User user) async {
    _setLoading(true);
    try {
      await _repository.createUser(user);
      await loadAllUsers(); // Recargar la lista
      _clearError();
    } catch (e) {
      _setError('Error al crear usuario: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(User user) async {
    _setLoading(true);
    try {
      await _repository.updateUser(user);
      await loadAllUsers(); // Recargar la lista
      _clearError();
    } catch (e) {
      _setError('Error al actualizar usuario: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String uid) async {
    _setLoading(true);
    try {
      await _repository.deleteUser(uid);
      await loadAllUsers(); // Recargar la lista
      _clearError();
    } catch (e) {
      _setError('Error al eliminar usuario: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getUser(String uid) async {
    _setLoading(true);
    try {
      _currentUser = await _repository.getUser(uid);
      _clearError();
    } catch (e) {
      _setError('Error al obtener usuario: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos de consulta
  Future<void> loadUsersByRole(String role) async {
    _setLoading(true);
    try {
      _repository.getUsersByRole(role).listen((users) {
        _users = users;
        notifyListeners();
      });
      _clearError();
    } catch (e) {
      _setError('Error al cargar usuarios por rol: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadVeterinariansByClinic(String clinicId) async {
    _setLoading(true);
    try {
      _repository.getVeterinariansByClinic(clinicId).listen((users) {
        _users = users;
        notifyListeners();
      });
      _clearError();
    } catch (e) {
      _setError('Error al cargar veterinarios por clínica: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllUsers() async {
    _setLoading(true);
    try {
      _repository.getAllUsers().listen((users) {
        _users = users;
        notifyListeners();
      });
      _clearError();
    } catch (e) {
      _setError('Error al cargar todos los usuarios: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserByEmail(String email) async {
    _setLoading(true);
    try {
      _repository.getUserByEmail(email).listen((user) {
        _currentUser = user;
        notifyListeners();
      });
      _clearError();
    } catch (e) {
      _setError('Error al cargar usuario por email: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos de actualización específicos
  Future<void> updateUserLastLogin(String uid) async {
    try {
      await _repository.updateUserLastLogin(uid);
      await getUser(uid); // Recargar el usuario actual
      _clearError();
    } catch (e) {
      _setError('Error al actualizar último login: $e');
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    _setLoading(true);
    try {
      await _repository.updateUserProfile(uid, updates);
      await getUser(uid); // Recargar el usuario actual
      _clearError();
    } catch (e) {
      _setError('Error al actualizar perfil: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    _setLoading(true);
    try {
      await _repository.updateUserRole(uid, newRole);
      await loadAllUsers(); // Recargar la lista
      _clearError();
    } catch (e) {
      _setError('Error al actualizar rol: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos de utilidad
  User? getUserById(String uid) {
    try {
      return _users.firstWhere((user) => user.uid == uid);
    } catch (e) {
      return null;
    }
  }

  List<User> getUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  List<User> getVeterinarians() {
    return getUsersByRole('veterinario');
  }

  List<User> getClients() {
    return getUsersByRole('client');
  }

  List<User> getAdmins() {
    return getUsersByRole('admin');
  }

  // Métodos privados para manejo de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }
} 