class UserModel {
  int? id;
  String? userId;
  String mobileNumber;
  String fullname;

  UserModel({
    this.id,this.userId,
    required this.mobileNumber,
    required this.fullname,
  });

  // Convert a UserModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'userId':userId,
      'fullname': fullname,
    };
  }

  // Convert a Map to a UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      userId: map['userId'],
      mobileNumber:map['mobileNumber'],
      fullname: map['fullname'],
    );
  }
}
