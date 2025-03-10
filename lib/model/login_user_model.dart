class LoginUserModel {
  int? id;
  String username;
  String password;
  String fullname;

  LoginUserModel({
    this.id,
    required this.username,
    required this.password,
    required this.fullname,
  });

  // Convert a UserModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullname': fullname,
    };
  }

  // Convert a Map to a UserModel
  factory LoginUserModel.fromMap(Map<String, dynamic> map) {
    return LoginUserModel(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      fullname: map['fullname'],
    );
  }
}
