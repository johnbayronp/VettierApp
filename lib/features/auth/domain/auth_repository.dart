abstract class AuthRepository {
  Future<void> registerWithEmail({required String email, required String password, required String displayName, int? age, String? location});
  Future<void> loginWithEmail({required String email, required String password});
  Future<void> logout();
  Stream<bool> get isLoggedIn;
  Future<dynamic> getCurrentUser();
} 