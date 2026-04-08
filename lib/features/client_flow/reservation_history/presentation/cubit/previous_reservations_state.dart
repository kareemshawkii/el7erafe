import 'package:el7erafe/features/client_flow/reservation_history/data/models/previous_reservation_model.dart';

abstract class PreviousReservationsState {}

class PreviousReservationsInitial extends PreviousReservationsState {}

class PreviousReservationsLoading extends PreviousReservationsState {}

class PreviousReservationsLoaded extends PreviousReservationsState {
  final List<PreviousReservationModel> reservations;
  PreviousReservationsLoaded(this.reservations);
}

class PreviousReservationsError extends PreviousReservationsState {
  final String message;
  PreviousReservationsError(this.message);
}

class PreviousReservationsUnauth extends PreviousReservationsState {}
