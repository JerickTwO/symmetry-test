/// Parámetros para el caso de uso de login.
/// Puro Dart — sin dependencias externas.
class SignInParams {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });
}
