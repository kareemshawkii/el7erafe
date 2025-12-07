sealed class PasswordStrengthState {
  final bool hasMinLength;
  final bool hasCapitalLetter;
  final bool hasNumber;
  final bool hasSpecialChar;

  const PasswordStrengthState({
    this.hasMinLength = false,
    this.hasCapitalLetter = false,
    this.hasNumber = false,
    this.hasSpecialChar = false,
  });
}

class PasswordStrengthInitial extends PasswordStrengthState {}

class PasswordStrengthUpdated extends PasswordStrengthState {
  const PasswordStrengthUpdated({
    required super.hasMinLength,
    required super.hasCapitalLetter,
    required super.hasNumber,
    required super.hasSpecialChar,
  });
}