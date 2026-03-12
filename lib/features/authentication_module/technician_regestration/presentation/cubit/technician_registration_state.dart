sealed class TechnicianRegistrationState {}

final class TechnicianRegInitial extends TechnicianRegistrationState {}

final class TechnicianRegLoading extends TechnicianRegistrationState {}

final class TechnicianRegServicesLoaded extends TechnicianRegistrationState {
  final List<String> services;
  TechnicianRegServicesLoaded({required this.services});
}

final class TechnicianRegServicesFailure extends TechnicianRegistrationState {
  final String error;
  TechnicianRegServicesFailure({required this.error});
}

final class TechnicianRegSuccess extends TechnicianRegistrationState {}

final class TechnicianRegFailure extends TechnicianRegistrationState {
  final String error;
  TechnicianRegFailure({required this.error});
}

final class TecnicianRegBlocked extends TechnicianRegistrationState {
  final String message;
  TecnicianRegBlocked({required this.message});
}
