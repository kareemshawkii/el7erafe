import 'package:el7erafe/features/authentication_module/otp_page/data/Repository/otp_repository.dart';
import 'package:el7erafe/features/authentication_module/otp_page/presentation/cubit/otp_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepository otpRepository;

  OtpCubit({required this.otpRepository}) : super(OtpInitial());

  Future<void> otpAuth(String email, String otpCode) async {
    emit(OtpLoading());
    final result = await otpRepository.verifyOtp(email, otpCode);

    result.fold(
      (failure) => emit(OtpFailure(error: failure.message)),
      (user) => emit(OtpSuccess(user: user)),
    );
  }
  
  Future<void> resendOtp(String email) async {
    emit(OtpLoading());
    final result = await otpRepository.resendOtp(email);

    result.fold(
      (failure) => emit(OtpFailure(error: failure.message)),
      (message) => emit(OtpResent()),
    );
  }
}