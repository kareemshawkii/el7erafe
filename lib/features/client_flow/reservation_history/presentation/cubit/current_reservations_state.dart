import 'package:el7erafe/features/client_flow/reservation_history/data/models/current_reservation_model.dart';

abstract class CurrentReservationsState {}

class CurrentInitial extends CurrentReservationsState {}

class CurrentLoading extends CurrentReservationsState {}

class CurrentLoaded extends CurrentReservationsState {
  final List<CurrentReservationModel> reservations;
  CurrentLoaded(this.reservations);
}

class CurrentError extends CurrentReservationsState {
  final String message;
  CurrentError(this.message);
}

class CurrentUnauth extends CurrentReservationsState {}

class CurrentActionLoading extends CurrentReservationsState {}

class CurrentActionSuccess extends CurrentReservationsState {
  final String message;
  CurrentActionSuccess(this.message);
}

class CurrentActionError extends CurrentReservationsState {
  final String message;
  CurrentActionError(this.message);
}

class PaymentLoading extends CurrentReservationsState {}

class PaymentSuccess extends CurrentReservationsState {
  final int reservationId;
  PaymentSuccess(this.reservationId);
}

class PaymentError extends CurrentReservationsState {
  final String message;
  PaymentError(this.message);
}

class RatingLoading extends CurrentReservationsState {}

class RatingSuccess extends CurrentReservationsState {}

class RatingError extends CurrentReservationsState {
  final String message;
  RatingError(this.message);
}
