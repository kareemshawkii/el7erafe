class ResetPasswordModel {
  final String password;

  ResetPasswordModel({
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
    };
  }
}