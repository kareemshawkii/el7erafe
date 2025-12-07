class EmailInputModel {
  final String email;

  EmailInputModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}