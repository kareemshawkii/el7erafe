sealed class TechnicianStatusState {}

final class TechnicianStatusInitial extends TechnicianStatusState {}

final class TechnicianStatusLoading extends TechnicianStatusState {}

final class TechnicianStatusApproved extends TechnicianStatusState {}

final class TechnicianStatusDenied extends TechnicianStatusState {
  final String message;
  final String status; 
  TechnicianStatusDenied({required this.message, required this.status});
}

final class TechnicianStatusError extends TechnicianStatusState {
  final String error;
  TechnicianStatusError({required this.error});
}

final class TechnicianStatusBlocked extends TechnicianStatusState {
  final String message;
  TechnicianStatusBlocked({required this.message});
}