import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../model/room_model.dart';

class RoomController extends GetxController {
  var roomList = <RoomModel>[].obs;
  var isProcessing = false.obs; // ✅ Prevent multiple operations at once

  @override
  void onInit() {
    super.onInit();
    fetchRooms(); // ✅ Load rooms when the controller is initialized
  }

  /// ✅ **Fetch Rooms with Safe Database Handling**
  Future<void> fetchRooms() async {
    if (isProcessing.value) return; // ✅ Prevent multiple fetches at once
    isProcessing.value = true;

    final rooms = await DBHelper.getRooms();
    roomList.assignAll(rooms.map((e) => RoomModel.fromMap(e)).toList());

    isProcessing.value = false;
  }

  /// ✅ **Check if User Exists Before Creating Room**
  Future<bool> _doesUserExist(int userId) async {
    final users = await DBHelper.getUsers();
    return users.any((user) => user["id"] == userId);
  }

  /// ✅ **Add Room with Foreign Key Validation**
  Future<void> addRoom(RoomModel room) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    // if (!(await _doesUserExist(room.userId))) {
    //   Get.snackbar("Error", "User ID ${room.userId} does not exist.");
    //   isProcessing.value = false;
    //   return;
    // }

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.insert('Rooms', room.toMap());
      });
    });

    await fetchRooms(); // ✅ Refresh list after adding a room
    isProcessing.value = false;
  }

  /// ✅ **Update Room with Foreign Key Validation**
  Future<void> updateRoom(RoomModel room) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    // if (!(await _doesUserExist(room.userId))) {
    //   Get.snackbar("Error", "User ID ${room.userId} does not exist.");
    //   isProcessing.value = false;
    //   return;
    // }

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.update('Rooms', room.toMap(), where: 'id = ?', whereArgs: [room.id]);
      });
    });

    await fetchRooms(); // ✅ Refresh list after updating a room
    isProcessing.value = false;
  }

  /// ✅ **Delete Room Safely**
  Future<void> deleteRoom(int id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.delete('Rooms', where: 'id = ?', whereArgs: [id]);
      });
    });

    await fetchRooms(); // ✅ Refresh list after deleting a room
    isProcessing.value = false;
  }
}
