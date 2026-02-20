import 'dart:typed_data';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/repository/storage_repository.dart';
import '../data_sources/storage_firebase_data_source.dart';

/// Implementación concreta del [StorageRepository] del domain layer.
/// Utiliza el data source para interactuar con Firebase Storage.
class StorageRepositoryImpl implements StorageRepository {
  final StorageFirebaseDataSource _dataSource;

  const StorageRepositoryImpl(this._dataSource);

  @override
  Future<DataState<String>> uploadArticleImage({
    required Uint8List data,
    required String fileName,
    required String articleId,
  }) async {
    try {
      final extension = fileName.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path =
          '${FirebaseConstants.mediaArticlesPath}/$articleId/${timestamp}_image.$extension';

      final url = await _dataSource.uploadImage(data: data, path: path);
      return DataState.success(url);
    } catch (e) {
      return DataState.error(e.toString());
    }
  }

  @override
  Future<void> deleteArticleImage(String imageUrl) async {
    await _dataSource.deleteImage(imageUrl);
  }
}
