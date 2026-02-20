/// Parámetros para el caso de uso de registro.
/// Puro Dart — sin dependencias externas.
class SignUpParams {
  final String email;
  final String password;
  final String fullName;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.fullName,
  });
}
