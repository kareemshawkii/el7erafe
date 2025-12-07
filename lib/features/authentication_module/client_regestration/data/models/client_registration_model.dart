class RegistrationRequestModel {
  final String name;
  final String phoneNumber;
  final String email;
  final String password;

  RegistrationRequestModel({
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
    };
  }
}