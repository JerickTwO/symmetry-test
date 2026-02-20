import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import 'storage_firebase_data_source.dart';

/// Implementación concreta del [StorageFirebaseDataSource].
/// Interactúa directamente con Firebase Storage.
class StorageFirebaseDataSourceImpl implements StorageFirebaseDataSource {
  final FirebaseStorage _storage;

  const StorageFirebaseDataSourceImpl(this._storage);

  @override
  Future<String> uploadImage({
    required Uint8List data,
    required String path,
  }) async {
    final ref = _storage.ref().child(path);

    // Determinar el contentType a partir de la extensión del archivo.
    // Sin esto, en Web se sube como 'application/octet-stream'
    // y la imagen no se muestra correctamente.
    final contentType = _getContentType(path);
    final metadata = SettableMetadata(contentType: contentType);

    final snapshot = await ref.putData(data, metadata);
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {
      // Si la imagen no existe en storage, no lanzar error.
    }
  }

  /// Retorna el MIME type según la extensión del archivo.
  String _getContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/png';
    }
  }
}
