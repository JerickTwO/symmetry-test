import 'dart:typed_data';

import '../../../../core/resources/data_state.dart';

/// Contrato del repositorio de almacenamiento.
/// Define las operaciones de subida y eliminación de imágenes.
/// Puro Dart — sin dependencias externas.
abstract class StorageRepository {
  /// Sube una imagen de artículo y retorna la URL de descarga.
  Future<DataState<String>> uploadArticleImage({
    required Uint8List data,
    required String fileName,
    required String articleId,
  });

  /// Elimina una imagen de artículo dada su URL.
  Future<void> deleteArticleImage(String imageUrl);
}
