import 'package:el7erafe/core/services/models/user.dart';

sealed class TechnicianOtpState {}

final class TechnicianOtpInitial extends TechnicianOtpState {}

final class TechnicianOtpLoading extends TechnicianOtpState {}

final class TechnicianOtpSuccess extends TechnicianOtpState {
  final User user;
  TechnicianOtpSuccess({required this.user});
}

final class TechnicianOtpFailure extends TechnicianOtpState {
  final String error;
  TechnicianOtpFailure({required this.error});
}

final class TechnicianOtpResent extends TechnicianOtpState {}

final class TechnicianOtpBlocked extends TechnicianOtpState {
  final String message;
  TechnicianOtpBlocked({required this.message});
}

final class TechnicianOtpRejected extends TechnicianOtpState {
  final String message;
  TechnicianOtpRejected({required this.message});
}

final class TechnicianOtpPending extends TechnicianOtpState {
  final String message;
  TechnicianOtpPending({required this.message});
}
