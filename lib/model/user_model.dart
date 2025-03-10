class UserModel {
  int? id;
  String username;
  String fullname;

  UserModel({
    this.id,
    required this.username,
    required this.fullname,
  });

  // Convert a UserModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'fullname': fullname,
    };
  }

  // Convert a Map to a UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      fullname: map['fullname'],
    );
  }
}
