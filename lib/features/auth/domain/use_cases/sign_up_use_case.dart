import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';
import 'sign_up_params.dart';

/// Caso de uso: Registrar un nuevo usuario.
/// Una sola responsabilidad — crear una cuenta nueva.
/// Puro Dart — sin dependencias externas.
class SignUpUseCase extends UseCase<DataState<UserEntity>, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<DataState<UserEntity>> call(SignUpParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
    );
  }
}
