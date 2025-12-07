sealed class TechnicianRegistrationState {}

final class TechnicianRegInitial extends TechnicianRegistrationState {}

final class TechnicianRegLoading extends TechnicianRegistrationState {}

final class TechnicianRegSuccess extends TechnicianRegistrationState {}

final class TechnicianRegFailure extends TechnicianRegistrationState {
  final String error;
  TechnicianRegFailure({required this.error});
}

final class TecnicianRegBlocked extends TechnicianRegistrationState {
  final String message;
  TecnicianRegBlocked({required this.message});
}