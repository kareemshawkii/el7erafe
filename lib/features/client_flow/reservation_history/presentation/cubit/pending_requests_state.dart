import '../../data/models/pending_request_model.dart';
import '../../data/models/offers_model.dart';

abstract class PendingRequestsState {}

class PendingRequestsInitial extends PendingRequestsState {}

class PendingRequestsLoading extends PendingRequestsState {}

class PendingRequestsLoaded extends PendingRequestsState {
  final List<PendingRequestModel> requests;
  PendingRequestsLoaded(this.requests);
}

class PendingRequestsError extends PendingRequestsState {
  final String error;
  PendingRequestsError(this.error);
}

class PendingRequestsUnauthorized extends PendingRequestsState {}

class OffersLoading extends PendingRequestsState {}

class OffersLoaded extends PendingRequestsState {
  final List<OfferModel> offers;
  OffersLoaded(this.offers);
}

class OfferActionLoading extends PendingRequestsState {}

class OfferActionSuccess extends PendingRequestsState {
  final String message;
  OfferActionSuccess(this.message);
}

class OfferActionError extends PendingRequestsState {
  final String error;
  OfferActionError(this.error);
}
