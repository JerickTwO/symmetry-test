import 'dart:typed_data';

/// Contrato del data source de almacenamiento de archivos.
/// Solo estas clases interactúan directamente con servicios externos (Firebase Storage).
abstract class StorageFirebaseDataSource {
  /// Sube una imagen al storage y retorna la URL de descarga.
  /// [data] - Bytes de la imagen a subir.
  /// [path] - Ruta dentro del bucket donde se almacenará.
  Future<String> uploadImage({
    required Uint8List data,
    required String path,
  });

  /// Elimina una imagen del storage dada su URL de descarga.
  Future<void> deleteImage(String imageUrl);
}
