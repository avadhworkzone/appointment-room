
import 'package:cal_room/widgets/add_edit_room_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/room_controller.dart';
import '../controller/user_controller.dart';
import 'export_pdf.dart';

class RoomScreen extends StatefulWidget {

  const RoomScreen({super.key});
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final RoomController roomController = Get.find<
      RoomController>();
 // ✅ Use Get.find() to avoid multiple instances
  final UserController userController = Get.find<
      UserController>();
  var isProcessing = false.obs;

  void confirmDelete(int id) {
    Get.defaultDialog(
      title: "Delete Room",
      middleText: "Are you sure you want to delete this room?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        isProcessing.value = true; // ✅ Prevent multiple clicks
        await Future.delayed(Duration(milliseconds: 300)); // ✅ Delay execution
        await roomController.deleteRoom(id);
        await roomController.fetchRooms(); // ✅ Refresh list after delete
        isProcessing.value = false;
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rooms")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addEditRoomBottomSheet(),
        child: Icon(Icons.add),
      ),
      body: Obx(() => roomController.roomList.isEmpty
          ? Center(child: Text("No rooms found. Add a new room!"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: roomController.roomList.length,
                    itemBuilder: (context, index) {
                      final room = roomController.roomList[index];
                      return Card(
                        elevation: 4,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: ListTile(
                          title: Text(room.roomName,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          // subtitle: Text("Room ID: ${room.id}\n${room.roomDesc}"),
                          subtitle: Text(room.roomDesc),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => addEditRoomBottomSheet(room: room)),
                              IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => confirmDelete(room.id!)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      exportRoomsAsPDF(roomController.roomList);
                      Get.snackbar("Export Successful",
                          "PDF saved in documents folder!");
                    },
                    child: Text("Export Rooms as PDF"),
                  ),
                ),
              ],
            )),
    );
  }
}
