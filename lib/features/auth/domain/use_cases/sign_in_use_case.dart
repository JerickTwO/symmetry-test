import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';
import 'sign_in_params.dart';

/// Caso de uso: Iniciar sesión.
/// Una sola responsabilidad — autenticar un usuario con email y contraseña.
/// Puro Dart — sin dependencias externas.
class SignInUseCase extends UseCase<DataState<UserEntity>, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<DataState<UserEntity>> call(SignInParams params) async {
    return await repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
