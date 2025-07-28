import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/auth_repository.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Método para logs solo en modo debug
  void _log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  @override
  Future<void> registerWithEmail({required String email, required String password, required String displayName, int? age, String? location}) async {
    try {
      _log('🔐 Iniciando registro de usuario: $email');
      
      // PASO 1: Crear usuario en Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      
      if (user == null) {
        throw Exception('No se pudo crear el usuario en Firebase Auth');
      }
      
      _log('✅ Usuario creado en Firebase Auth con UID: ${user.uid}');
      
      // PASO 2: Guardar en Firestore INMEDIATAMENTE
      // NOTA: Este paso es crítico y debe ejecutarse antes de updateDisplayName
      // para evitar que el error PigeonUserDetails interrumpa el flujo
      final userData = {
        'uid': user.uid,
        'name': displayName,
        'email': email,
        'phone': '',
        'photoURL': '',
        'role': 'client',
        'address': {
          'street': '',
          'city': location ?? '',
          'zip': ''
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'age': age,
        'location': location,
        'specialty': '',
        'clinicId': '',
        'experience': '',
        'education': '',
      };
      
      _log('📝 Guardando en Firestore...');
      await _firestore.collection('users').doc(user.uid).set(userData);
      _log('✅ Usuario guardado en Firestore exitosamente');
      
      // PASO 3: Verificar que se guardó correctamente
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        _log('✅ Verificación: Documento existe en Firestore con ID: ${docSnapshot.id}');
        _log('✅ Datos guardados: ${docSnapshot.data()}');
      } else {
        _log('❌ ERROR: Documento no existe en Firestore después de guardarlo');
        throw Exception('No se pudo guardar el usuario en Firestore');
      }
      
      // PASO 4: Intentar actualizar displayName (opcional, puede fallar)
      // NOTA: Este paso puede fallar con error PigeonUserDetails, pero no es crítico
      // porque los datos ya están guardados en Firestore
      try {
        await user.updateDisplayName(displayName);
        _log('✅ DisplayName actualizado: $displayName');
      } catch (e) {
        _log('⚠️ Error al actualizar displayName (no crítico): $e');
        // Error no crítico, ignorar
      }
      
      _log('🎉 Registro completado exitosamente');
      
    } catch (e) {
      _log('❌ Error en registerWithEmail: $e');
      
      // MANEJO DE EMERGENCIA: Si es un error de PigeonUserDetails, verificar si el usuario se creó
      // y guardarlo en Firestore de todas formas
      if (e.toString().contains('PigeonUserDetails')) {
        final currentUser = _firebaseAuth.currentUser;
        if (currentUser != null) {
          _log('⚠️ Error de PigeonUserDetails, pero usuario existe. Usando método de emergencia...');
          // Usar método de emergencia
          await _saveUserToFirestore(currentUser.uid, displayName, email, age, location);
          return; // No re-lanzar el error
        }
      }
      
      rethrow;
    }
  }

  @override
  Future<void> loginWithEmail({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<bool> get isLoggedIn => _firebaseAuth.authStateChanges().map((user) => user != null);

  @override
  Future<dynamic> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  /// Método de emergencia para guardar usuario directamente en Firestore
  Future<void> _saveUserToFirestore(String uid, String displayName, String email, int? age, String? location) async {
    try {
      _log('🚨 MÉTODO DE EMERGENCIA: Guardando usuario directamente en Firestore');
      
      final userData = {
        'uid': uid,
        'name': displayName,
        'email': email,
        'phone': '',
        'photoURL': '',
        'role': 'client',
        'address': {
          'street': '',
          'city': location ?? '',
          'zip': ''
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'age': age,
        'location': location,
        'specialty': '',
        'clinicId': '',
        'experience': '',
        'education': '',
      };
      
      await _firestore.collection('users').doc(uid).set(userData);
      _log('✅ Usuario guardado exitosamente con método de emergencia');
      
      // Verificar
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        _log('✅ Verificación exitosa: Usuario existe en Firestore');
      } else {
        _log('❌ ERROR: Usuario no existe después del método de emergencia');
        throw Exception('No se pudo guardar el usuario en Firestore');
      }
    } catch (e) {
      _log('❌ Error en método de emergencia: $e');
      rethrow;
    }
  }
} 