class UserModel {
  int? id;
  String? userId;
  String? mobileNumber;
  String fullname;
  String password;
  String role;

  UserModel({
    this.id,this.userId,
     this.mobileNumber,
    required this.fullname,
    required this.password,
    required this.role,
  });

  // Convert a UserModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id??0,
      'fullname': fullname,
      'userId':userId??"",
      'mobileNumber': mobileNumber??"",
      'password': password,
      'role': role,
    };
  }

  // Convert a Map to a UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      userId: map['userId'],
      mobileNumber:map['mobileNumber'],
      fullname: map['fullname'],
      password: map['password'],
      role: map['role'],
    );
  }
}
