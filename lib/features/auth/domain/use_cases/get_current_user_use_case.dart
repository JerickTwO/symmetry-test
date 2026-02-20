import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repository/auth_repository.dart';

/// Caso de uso: Obtener el usuario actual autenticado.
/// Puro Dart — sin dependencias externas.
class GetCurrentUserUseCase extends UseCase<DataState<UserEntity?>, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<DataState<UserEntity?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
