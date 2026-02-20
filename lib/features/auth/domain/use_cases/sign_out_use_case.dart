import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

/// Caso de uso: Cerrar sesión.
/// Una sola responsabilidad — desautenticar al usuario actual.
/// Puro Dart — sin dependencias externas.
class SignOutUseCase extends UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.signOut();
  }
}
