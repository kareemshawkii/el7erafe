import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/reset_password_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/reset_password_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final ResetPasswordRepository resetPasswordRepository;

  ResetPasswordCubit({required this.resetPasswordRepository})
      : super(ResetPasswordInitial());

  Future<void> sendPassword(String password) async {
    emit(ResetPasswordLoading());
    final result = await resetPasswordRepository.resetPassword(
      password: password,
    );

    result.fold(
      (failure) => emit(ResetPasswordInvalid(errorMessage: failure.message)),
      (message) => emit(ResetPasswordValid()),
    );
  }
}