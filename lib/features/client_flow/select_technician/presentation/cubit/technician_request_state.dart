import 'package:el7erafe/features/client_flow/select_technician/data/models/technicians_model.dart';

abstract class TechnicianRequestState {}

class TechnicianRequestInitial extends TechnicianRequestState {}

class FetchTechniciansLoading extends TechnicianRequestState {}

class FetchTechniciansSuccess extends TechnicianRequestState {
  final List<TechniciansModel> data;
  FetchTechniciansSuccess(this.data);
}

class FetchTechniciansError extends TechnicianRequestState {
  final String message;
  FetchTechniciansError(this.message);
}

class SubmitReservationLoading extends TechnicianRequestState {}

class SubmitReservationSuccess extends TechnicianRequestState {
  final String successMessage;
  SubmitReservationSuccess(this.successMessage);
}

class ServiceRequestConflict extends TechnicianRequestState {
  final String message;
  ServiceRequestConflict(this.message);
}

class SubmitReservationError extends TechnicianRequestState {
  final String message;
  SubmitReservationError(this.message);
}

class TechnicianRequestUnauth extends TechnicianRequestState {
  final String message;
  TechnicianRequestUnauth(this.message);
}
