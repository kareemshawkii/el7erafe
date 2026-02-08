import 'package:el7erafe/features/authentication_module/otp_page/data/Repository/otp_repository.dart';
import 'package:el7erafe/features/authentication_module/otp_page/presentation/cubit/technician_otp_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TechnicianOtpCubit extends Cubit<TechnicianOtpState> {
  final OtpRepository otpRepository;

  TechnicianOtpCubit({required this.otpRepository})
      : super(TechnicianOtpInitial());

  Future<void> otpAuth(String email, String otpCode) async {
    emit(TechnicianOtpLoading());
    final result = await otpRepository.verifyTechnicianOtp(email, otpCode);

    result.fold(
      (failure) {
        if (failure.message.contains('PENDING')) {
          final message = 'طلبك بيتراجع حاليا وهنرد عليك خلال 24 ساعة....';
          emit(TechnicianOtpPending(
            message: message,
          ));
        } else if (failure.message.contains('BLOCKED')) {
          emit(TechnicianOtpBlocked(
            message:
                'تم حظر حسابك. الرجاء التواصل مع الدعم لمزيد من المعلومات.',
          ));
        } else if (failure.message.contains('REJECTED')) {
          final rejectionReason =
              'تم رفض طلبك. الرجاء تعديل المعلومات وإعادة التقديم.';
          emit(TechnicianOtpRejected(
            message: rejectionReason,
          ));
        } else {
          emit(TechnicianOtpFailure(error: failure.message));
        }
      },
      (user) => emit(TechnicianOtpSuccess(user: user)),
    );
  }

  Future<void> resendOtp(String email) async {
    emit(TechnicianOtpLoading());
    final result = await otpRepository.resendOtp(email);

    result.fold(
      (failure) => emit(TechnicianOtpFailure(error: failure.message)),
      (message) => emit(TechnicianOtpResent()),
    );
  }
}