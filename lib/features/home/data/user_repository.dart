import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/user_model.dart';

// Interfaz abstracta para el repositorio de usuarios
abstract class UserRepository {
  // CRUD básico
  Future<void> createUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String uid);
  Future<User?> getUser(String uid);
  
  // Consultas específicas
  Stream<List<User>> getUsersByRole(String role);
  Stream<List<User>> getVeterinariansByClinic(String clinicId);
  Stream<List<User>> getAllUsers();
  Stream<User?> getUserByEmail(String email);
  
  // Actualizaciones específicas
  Future<void> updateUserLastLogin(String uid);
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates);
  Future<void> updateUserRole(String uid, String newRole);
}

// Implementación con Firebase
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createUser(User user) async {
    try {
      // Usar el uid como ID del documento
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  @override
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  @override
  Future<User?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  @override
  Stream<List<User>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<User>> getVeterinariansByClinic(String clinicId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'veterinario')
        .where('clinicId', isEqualTo: clinicId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<List<User>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<User?> getUserByEmail(String email) {
    return _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return User.fromFirestore(snapshot.docs.first);
          }
          return null;
        });
  }

  @override
  Future<void> updateUserLastLogin(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'lastLogin': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al actualizar último login: $e');
    }
  }

  @override
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update(updates);
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  @override
  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'role': newRole,
      });
    } catch (e) {
      throw Exception('Error al actualizar rol: $e');
    }
  }
} 