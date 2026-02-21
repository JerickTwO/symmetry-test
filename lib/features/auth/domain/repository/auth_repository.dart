import '../../../../core/resources/data_state.dart';
import '../entities/user_entity.dart';

/// Contrato del repositorio de autenticación.
/// Define las operaciones disponibles sin conocer la implementación.
/// Puro Dart — sin dependencias externas.
abstract class AuthRepository {
  Future<DataState<UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<DataState<UserEntity?>> getCurrentUser();
}
