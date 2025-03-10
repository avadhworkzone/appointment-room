class RoomModel {
  int? id;
  String roomName;
  String roomDesc;
  int userId;

  RoomModel({
    this.id,
    required this.roomName,
    required this.roomDesc,
    required this.userId,
  });

  // Convert a RoomModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_name': roomName,
      'room_desc': roomDesc,
      'user_id': userId,
    };
  }

  // Convert a Map to a RoomModel
  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'],
      roomName: map['room_name'],
      roomDesc: map['room_desc'],
      userId: map['user_id'],
    );
  }
}
