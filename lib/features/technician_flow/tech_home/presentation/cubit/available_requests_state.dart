import 'package:el7erafe/features/technician_flow/tech_home/data/models/available_request_model.dart';

sealed class AvailableRequestsState {}

final class AvailableRequestsInitial extends AvailableRequestsState {}

final class AvailableRequestsLoading extends AvailableRequestsState {}

final class AvailableRequestsLoaded extends AvailableRequestsState {
  final List<AvailableRequestModel> requests;
  AvailableRequestsLoaded(this.requests);
}

final class AvailableRequestsError extends AvailableRequestsState {
  final String error;
  AvailableRequestsError(this.error);
}

final class AvailableRequestsUnauthorized extends AvailableRequestsState {}
