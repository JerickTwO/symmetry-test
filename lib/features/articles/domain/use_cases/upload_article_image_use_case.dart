import 'dart:typed_data';

import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/storage_repository.dart';

/// Parámetros para subir una imagen de artículo.
class UploadArticleImageParams {
  final Uint8List data;
  final String fileName;
  final String articleId;

  const UploadArticleImageParams({
    required this.data,
    required this.fileName,
    required this.articleId,
  });
}

/// Caso de uso: Subir imagen de un artículo a Firebase Storage.
/// Una sola responsabilidad — subir imagen y retornar URL.
/// Puro Dart — sin dependencias externas.
class UploadArticleImageUseCase
    extends UseCase<DataState<String>, UploadArticleImageParams> {
  final StorageRepository repository;

  UploadArticleImageUseCase(this.repository);

  @override
  Future<DataState<String>> call(UploadArticleImageParams params) async {
    return await repository.uploadArticleImage(
      data: params.data,
      fileName: params.fileName,
      articleId: params.articleId,
    );
  }
}
