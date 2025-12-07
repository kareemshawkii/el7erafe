class EmailInputState {}

class EmailInputInitial extends EmailInputState {}

class EmailInputLoading extends EmailInputState {}

class EmailInputValid extends EmailInputState {
  final String email;
  EmailInputValid({required this.email});
}

class EmailInputInvalid extends EmailInputState {
  final String errorMessage;

  EmailInputInvalid({required this.errorMessage});
}