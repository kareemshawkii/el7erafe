sealed class TechnicianResubmitState {}

final class TechnicianResubmitInitial extends TechnicianResubmitState {}

final class TechnicianResubmitLoading extends TechnicianResubmitState {}

final class TechnicianResubmitSuccess extends TechnicianResubmitState {}

final class TechnicianResubmitFailure extends TechnicianResubmitState {
  final String error;
  TechnicianResubmitFailure({required this.error});
}

final class TechnicianResubmitBlocked extends TechnicianResubmitState {
  final String message;
  TechnicianResubmitBlocked({required this.message});
}