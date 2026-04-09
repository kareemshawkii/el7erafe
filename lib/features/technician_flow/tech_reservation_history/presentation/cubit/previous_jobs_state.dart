import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/previous_jobs_model.dart';

abstract class PreviousJobsState {}

class PreviousJobsInitial extends PreviousJobsState {}

class PreviousJobsLoading extends PreviousJobsState {}

class PreviousJobsLoaded extends PreviousJobsState {
  final List<PreviousJobsModel> jobs;
  PreviousJobsLoaded(this.jobs);
}

class PreviousJobsError extends PreviousJobsState {
  final String message;
  PreviousJobsError(this.message);
}

class PreviousJobsUnauth extends PreviousJobsState {}
