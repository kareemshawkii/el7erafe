import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/technician_calender_model.dart';

abstract class TechCalendarState {}

class TechCalendarInitial extends TechCalendarState {}

class TechCalendarLoading extends TechCalendarState {}

class TechCalendarLoaded extends TechCalendarState {
  final List<TechReservationModel> reservations;
  final DateTime selectedDate;
  TechCalendarLoaded(this.reservations, this.selectedDate);
}

class TechCalendarError extends TechCalendarState {
  final String error;
  TechCalendarError(this.error);
}

class TechCalendarUnauthorized extends TechCalendarState {}

class ActionLoading extends TechCalendarState {}

class ActionSuccess extends TechCalendarState {
  final String message;
  ActionSuccess(this.message);
}

class ActionError extends TechCalendarState {
  final String error;
  ActionError(this.error);
}
