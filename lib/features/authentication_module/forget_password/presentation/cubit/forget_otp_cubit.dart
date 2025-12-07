import 'package:el7erafe/features/authentication_module/forget_password/data/repositories/otp_forget_repo.dart';
import 'package:el7erafe/features/authentication_module/forget_password/presentation/cubit/forget_otp_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgetOtpCubit extends Cubit<ForgetOtpState> {
  final OtpForgetRepository otpForgetRepository;

  ForgetOtpCubit({required this.otpForgetRepository}) : super(ForgetOtpInitial());

  Future<void> otpAuth(String email, String otpCode) async {
    emit(ForgetOtpLoading());
    final result = await otpForgetRepository.verifyOtp(email, otpCode);
    result.fold(
      (failure) => emit(ForgetOtpFailure(error: failure.message)),
      (_) => emit(ForgetOtpSuccess()),
    );
  }
  
  Future<void> resendOtp(String email) async {
    emit(ForgetOtpLoading());
    final result = await otpForgetRepository.resendOtp(email);

    result.fold(
      (failure) => emit(ForgetOtpFailure(error: failure.message)),
      (_) => emit(ForgetOtpResent()),
    );
  }
}