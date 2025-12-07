
sealed class ClientRegistrationState {}

final class ClientRegInitial extends ClientRegistrationState {}

final class ClientRegLoading extends ClientRegistrationState {}

class ClientRegSuccess extends ClientRegistrationState {
  final String message;
  ClientRegSuccess({required this.message});
}

final class ClientRegFailure extends ClientRegistrationState {
  final String error;
  ClientRegFailure({required this.error});
}

