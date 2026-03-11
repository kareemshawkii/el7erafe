import '../../data/models/pending_request_model.dart';

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