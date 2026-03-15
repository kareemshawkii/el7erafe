import 'package:el7erafe/features/technician_flow/tech_schedule/data/models/tech_schedule_model.dart';

abstract class TechScheduleState {}

class TechScheduleInitial extends TechScheduleState {}

class TechScheduleLoading extends TechScheduleState {}

class TechScheduleLoaded extends TechScheduleState {
  final List<TechScheduleModel> schedule;
  TechScheduleLoaded(this.schedule);
}

class TechScheduleUpdateLoading extends TechScheduleState {}

class TechScheduleUpdateSuccess extends TechScheduleState {
  final String message;
  TechScheduleUpdateSuccess(this.message);
}

class TechScheduleError extends TechScheduleState {
  final String error;
  TechScheduleError(this.error);
}

class TechScheduleUnauthorized extends TechScheduleState {}
