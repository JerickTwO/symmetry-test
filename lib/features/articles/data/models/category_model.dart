import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/category_entity.dart';

/// Modelo de datos que extiende la entidad de negocio [CategoryEntity].
/// Responsable de parsear datos desde/hacia Firebase Firestore.
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.id,
    required super.name,
  });

  /// Crea un [CategoryModel] a partir de datos crudos (Map).
  /// Este es el factory principal para conversión de datos externos → modelo.
  factory CategoryModel.fromRawData(Map<String, dynamic> data) {
    return CategoryModel(
      id: data['id'] as String?,
      name: data['name'] as String? ?? '',
    );
  }

  /// Crea un [CategoryModel] a partir de un documento de Firestore.
  /// Delega a [fromRawData] después de extraer y normalizar los datos.
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel.fromRawData({
      ...data,
      'id': doc.id,
    });
  }

  /// Convierte el modelo a una entidad pura del dominio.
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
    );
  }

  /// Convierte el modelo a un mapa para guardar en Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameLower': name.toLowerCase(),
    };
  }
}
