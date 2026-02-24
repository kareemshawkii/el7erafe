abstract class ServiceRequestState {}

class ServiceRequestInitial extends ServiceRequestState {}

class ServiceRequestLoading extends ServiceRequestState {}

class ServiceRequestSuccess extends ServiceRequestState {}

class ServiceRequestConflict extends ServiceRequestState {
  final String message;
  ServiceRequestConflict(this.message);
}

class ServiceRequestError extends ServiceRequestState {
  final String message;
  ServiceRequestError(this.message);
}

class ServiceRequestImageUpdated extends ServiceRequestState {}

class ServiceRequestUnauthorized extends ServiceRequestState {
  String unauthMessage;
  ServiceRequestUnauthorized(this.unauthMessage);
}
