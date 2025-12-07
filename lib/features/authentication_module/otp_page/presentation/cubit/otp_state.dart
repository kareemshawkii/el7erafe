import 'package:el7erafe/core/services/models/user.dart';

sealed class OtpState {}

final class OtpInitial extends OtpState {}
final class OtpLoading extends OtpState {}
final class OtpSuccess extends OtpState {
  final User user;
  OtpSuccess({required this.user});
}
final class OtpFailure extends OtpState {
  final String error;
  OtpFailure({required this.error});
}
final class OtpResent extends OtpState {}