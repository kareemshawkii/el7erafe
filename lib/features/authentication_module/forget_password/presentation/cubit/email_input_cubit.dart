import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/email_input_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'email_input_state.dart';

class EmailInputCubit extends Cubit<EmailInputState> {
  final EmailInputRepository emailInputRepository;

  EmailInputCubit({required this.emailInputRepository})
      : super(EmailInputInitial());

  Future<void> sendEmail(String email) async {
    emit(EmailInputLoading());
    final result = await emailInputRepository.sendEmail(
      email: email,
    );

    result.fold(
      (failure) => emit(EmailInputInvalid(errorMessage: failure.message)),
      (message) => emit(EmailInputValid(email: email)),
    );
  }
}