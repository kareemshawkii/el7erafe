class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPasswordLoading extends ResetPasswordState {}

class ResetPasswordValid extends ResetPasswordState {
}

class ResetPasswordInvalid extends ResetPasswordState {
  final String errorMessage;

  ResetPasswordInvalid({required this.errorMessage});
}