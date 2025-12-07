sealed class ForgetOtpState {}

final class ForgetOtpInitial extends ForgetOtpState {}
final class ForgetOtpLoading extends ForgetOtpState {}
final class ForgetOtpSuccess extends ForgetOtpState {}

final class ForgetOtpFailure extends ForgetOtpState {
  final String error;
  ForgetOtpFailure({required this.error});
}
final class ForgetOtpResent extends ForgetOtpState {}