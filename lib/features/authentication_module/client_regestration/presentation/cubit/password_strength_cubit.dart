import 'package:flutter_bloc/flutter_bloc.dart';
import 'password_strength_state.dart';

class PasswordStrengthCubit extends Cubit<PasswordStrengthState> {
  PasswordStrengthCubit() : super(PasswordStrengthInitial());

  final RegExp _capitalLetterRegex = RegExp(r'[A-Z]');
  final RegExp _numberRegex = RegExp(r'[0-9]');
  final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  void validatePassword(String password) {
    final bool hasMinLength = password.length >= 10;
    final bool hasCapitalLetter = _capitalLetterRegex.hasMatch(password);
    final bool hasNumber = _numberRegex.hasMatch(password);
    final bool hasSpecialChar = _specialCharRegex.hasMatch(password);

    emit(PasswordStrengthUpdated(
      hasMinLength: hasMinLength,
      hasCapitalLetter: hasCapitalLetter,
      hasNumber: hasNumber,
      hasSpecialChar: hasSpecialChar,
    ));
  }
}