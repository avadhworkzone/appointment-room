import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../model/room_model.dart';

class RoomController extends GetxController {
  var roomList = <RoomModel>[].obs;
  var isProcessing = false.obs; // ✅ Prevents multiple simultaneous operations

  @override
  void onInit() {
    super.onInit();
    fetchRooms(); // ✅ Load rooms when the controller is initialized
  }

  /// ✅ **Optimized Fetch Method**
  fetchRooms() async {
    if (isProcessing.value) return; // ✅ Prevents multiple fetches at once
    isProcessing.value = true;

    final rooms = await DBHelper.getRooms();
    roomList.assignAll(rooms.map((e) => RoomModel.fromMap(e)).toList());

    isProcessing.value = false;
  }

  /// ✅ **Transaction-Based Insert**
  Future<void> addRoom(RoomModel room) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.insert('Rooms', room.toMap());
      });
    });

    await fetchRooms(); // ✅ Refresh list after adding a room
    isProcessing.value = false;
  }

  /// ✅ **Transaction-Based Update**
  Future<void> updateRoom(RoomModel room) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.update('Rooms', room.toMap(), where: 'id = ?', whereArgs: [room.id]);
      });
    });

    await fetchRooms(); // ✅ Refresh list after updating a room
    isProcessing.value = false;
  }

  /// ✅ **Transaction-Based Delete**
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
