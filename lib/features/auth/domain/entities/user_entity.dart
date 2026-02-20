/// Entidad pura de Dart que representa un usuario en el negocio.
/// No tiene dependencia de ningún paquete externo ni de Flutter.
class UserEntity {
  final String uid;
  final String email;
  final String fullName;
  final DateTime? createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.fullName,
    this.createdAt,
  });
}
