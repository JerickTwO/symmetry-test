import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/article_entity.dart';

/// Modelo de datos que extiende la entidad de negocio [ArticleEntity].
/// Responsable de parsear datos desde/hacia Firebase Firestore.
class ArticleModel extends ArticleEntity {
  const ArticleModel({
    super.id,
    required super.title,
    required super.content,
    super.thumbnailURL,
    super.category,
    super.createdAt,
    super.updatedAt,
  });

  /// Crea un [ArticleModel] a partir de datos crudos (Map).
  /// Este es el factory principal para conversión de datos externos → modelo.
  factory ArticleModel.fromRawData(Map<String, dynamic> data) {
    return ArticleModel(
      id: data['id'] as String?,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      thumbnailURL: data['thumbnailURL'] as String?,
      category: data['category'] as String?,
      createdAt:
          data['createdAt'] is DateTime ? data['createdAt'] as DateTime : null,
      updatedAt:
          data['updatedAt'] is DateTime ? data['updatedAt'] as DateTime : null,
    );
  }

  /// Crea un [ArticleModel] a partir de un documento de Firestore.
  /// Delega a [fromRawData] después de extraer y normalizar los datos.
  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleModel.fromRawData({
      ...data,
      'id': doc.id,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
      'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
    });
  }

  /// Convierte el modelo a una entidad pura del dominio.
  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      title: title,
      content: content,
      thumbnailURL: thumbnailURL,
      category: category,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convierte el modelo a un mapa para guardar en Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'thumbnailURL': thumbnailURL,
      'category': category,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
