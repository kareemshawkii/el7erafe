import 'package:el7erafe/features/technician_flow/tech_home/data/models/available_request_model.dart';
import 'package:el7erafe/features/technician_flow/tech_home/data/models/in_progress_reservation_model.dart';

sealed class AvailableRequestsState {}

final class AvailableRequestsInitial extends AvailableRequestsState {}

final class AvailableRequestsLoading extends AvailableRequestsState {}

final class AvailableRequestsLoaded extends AvailableRequestsState {
  final List<AvailableRequestModel> requests;
  final InProgressReservationModel? inProgress;

  AvailableRequestsLoaded(this.requests, {this.inProgress});
}

final class AvailableRequestsError extends AvailableRequestsState {
  final String error;
  AvailableRequestsError(this.error);
}

final class AvailableRequestsUnauthorized extends AvailableRequestsState {}

final class MakeOfferLoading extends AvailableRequestsState {}

final class MakeOfferSuccess extends AvailableRequestsState {
  final String message;
  MakeOfferSuccess(this.message);
}

final class MakeOfferError extends AvailableRequestsState {
  final String error;
  MakeOfferError(this.error);
}

final class DeclineRequestLoading extends AvailableRequestsState {}

final class DeclineRequestSuccess extends AvailableRequestsState {
  final String message;
  DeclineRequestSuccess(this.message);
}

final class DeclineRequestError extends AvailableRequestsState {
  final String error;
  DeclineRequestError(this.error);
}

final class CompleteJobLoading extends AvailableRequestsState {}

final class CompleteJobSuccess extends AvailableRequestsState {
  final String message;
  final int reservationId;
  CompleteJobSuccess(this.message, this.reservationId);
}

final class CompleteJobError extends AvailableRequestsState {
  final String error;
  CompleteJobError(this.error);
}

class PaymentReceivedSuccess extends AvailableRequestsState {}
