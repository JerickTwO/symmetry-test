import '../../../../core/resources/data_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/auth_firebase_data_source.dart';

/// Implementación concreta del [AuthRepository] del domain layer.
/// Cumple el contrato definido en la capa de negocio.
/// Utiliza el data source para interactuar con Firebase.
class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<DataState<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _dataSource.signIn(
        email: email,
        password: password,
      );
      return DataState.success(model.toEntity());
    } catch (e) {
      return DataState.error(e.toString());
    }
  }

  @override
  Future<DataState<UserEntity>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final model = await _dataSource.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      return DataState.success(model.toEntity());
    } catch (e) {
      return DataState.error(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  Future<DataState<UserEntity?>> getCurrentUser() async {
    try {
      final model = await _dataSource.getCurrentUser();
      return DataState.success(model?.toEntity());
    } catch (e) {
      return DataState.error(e.toString());
    }
  }
}
