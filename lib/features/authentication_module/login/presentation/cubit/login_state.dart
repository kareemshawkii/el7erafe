sealed class LoginState {}

final class AuthInitial extends LoginState {}

final class AuthLoading extends LoginState {}

final class AuthSuccess extends LoginState {}

final class OtpSent extends LoginState {}

final class TechnicianOtpSent extends LoginState {}

final class AuthRejected extends LoginState {}

final class AuthPending extends LoginState {}

final class AuthFailure extends LoginState {
  final String error;
  AuthFailure({required this.error});
}

final class AuthBlocked extends LoginState {
  final String error;
  AuthBlocked({required this.error});
}