/// Eventos del BLoC de autenticación.
abstract class AuthEvent {
  const AuthEvent();
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
