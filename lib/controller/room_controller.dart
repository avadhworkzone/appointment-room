import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../model/room_model.dart';

class RoomController extends GetxController {
  var roomList = <RoomModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms(); // Load rooms when the controller is initialized
  }

   fetchRooms() async {
    final rooms = await DBHelper.getRooms();
    roomList.value = rooms.map((e) => RoomModel.fromMap(e)).toList();
  }

  Future<void> addRoom(RoomModel room) async {
    await DBHelper.insertRoom(room.toMap());
    fetchRooms(); // Refresh list after adding a room
  }

  Future<void> updateRoom(RoomModel room) async {
    await DBHelper.updateRoom(room.toMap(), room.id!);
    fetchRooms(); // Refresh list after updating a room
  }

  Future<void> deleteRoom(int id) async {
    await DBHelper.deleteRoom(id);
    fetchRooms(); // Refresh list after deleting a room
  }
}
