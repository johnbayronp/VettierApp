import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<void> registerWithEmail({required String email, required String password, required String displayName, int? age, String? location}) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    await userCredential.user?.updateDisplayName(displayName);
    // age y location recibidos pero no usados aquí
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
} 