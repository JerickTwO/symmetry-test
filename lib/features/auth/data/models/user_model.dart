import '../../domain/entities/user_entity.dart';

/// Modelo de datos que extiende la entidad de negocio [UserEntity].
/// Responsable de parsear datos desde/hacia Firebase Firestore.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.fullName,
    super.createdAt,
  });

  /// Convierte el modelo a una entidad pura del dominio.
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      fullName: fullName,
      createdAt: createdAt,
    );
  }

  /// Crea un [UserModel] a partir de datos crudos (Map).
  /// Este es el factory principal para conversión de datos externos → modelo.
  factory UserModel.fromRawData(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      fullName: data['fullName'] as String,
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt'] as DateTime
          : data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : null,
    );
  }

  /// Convierte el modelo a un mapa JSON para guardar en Firestore.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
