import '../models/user_model.dart';

/// Contrato del data source de autenticación.
/// Solo estas clases interactúan directamente con servicios externos (Firebase).
abstract class AuthFirebaseDataSource {
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();
}
