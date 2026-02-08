class User {
  final String? token;
  final String? name;
  final String? id;
  final String? type;

  User({this.token, this.name, this.id, this.type});
}

class TempTechnician {
  final String? tempToken;

  TempTechnician({this.tempToken});
}

class UserModel extends User {
  UserModel({super.token, super.name, super.id, super.type});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'],
      name: json['userName'],
      id: json['userId'],
      type: json['type'],
    );
  }
}
