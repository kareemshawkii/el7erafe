
import 'package:el7erafe/features/technician_flow/tech_reservation_history/data/models/pending_offer_model.dart';

abstract class PendingOffersState {}

class PendingOffersInitial extends PendingOffersState {}

class PendingOffersLoading extends PendingOffersState {}

class PendingOffersLoaded extends PendingOffersState {
  final List<PendingOfferModel> offers;
  PendingOffersLoaded(this.offers);
}

class PendingOffersError extends PendingOffersState {
  final String error;
  PendingOffersError(this.error);
}

class PendingOffersUnauthorized extends PendingOffersState {}