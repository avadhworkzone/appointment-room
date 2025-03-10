import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/room_controller.dart';
import '../model/room_model.dart';
import 'export_pdf.dart';

class RoomScreen extends StatelessWidget {
  final RoomController roomController = Get.put(RoomController());

  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController roomDescController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();

  var isProcessing = false.obs; // ✅ Prevents multiple clicks and database locks

  void showRoomDialog({RoomModel? room}) {
    if (room != null) {
      roomNameController.text = room.roomName;
      roomDescController.text = room.roomDesc;
      userIdController.text = room.userId.toString();
    } else {
      roomNameController.clear();
      roomDescController.clear();
      userIdController.clear();
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(room == null ? "Add Room" : "Edit Room",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: roomNameController, decoration: InputDecoration(labelText: "Room Name")),
            TextField(controller: roomDescController, decoration: InputDecoration(labelText: "Room Description")),
            TextField(controller: userIdController, decoration: InputDecoration(labelText: "User ID"), keyboardType: TextInputType.number),
            SizedBox(height: 10),
            Obx(() => ElevatedButton(
              onPressed: isProcessing.value
                  ? null
                  : () async {
                if (roomNameController.text.isEmpty || userIdController.text.isEmpty) {
                  Get.snackbar("Error", "Room Name and User ID are required");
                  return;
                }

                isProcessing.value = true; // ✅ Prevent multiple clicks
                await Future.delayed(Duration(milliseconds: 500)); // ✅ Ensure previous writes finish

                if (room == null) {
                  await roomController.addRoom(RoomModel(
                    roomName: roomNameController.text,
                    roomDesc: roomDescController.text,
                    userId: int.parse(userIdController.text),
                  ));
                } else {
                  await roomController.updateRoom(RoomModel(
                    id: room.id,
                    roomName: roomNameController.text,
                    roomDesc: roomDescController.text,
                    userId: int.parse(userIdController.text),
                  ));
                }

                isProcessing.value = false;
                Get.back();
              },
              child: Text(room == null ? "Add Room" : "Update Room"),
            )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void confirmDelete(int id) {
    Get.defaultDialog(
      title: "Delete Room",
      middleText: "Are you sure you want to delete this room?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        isProcessing.value = true; // ✅ Prevent multiple clicks
        await Future.delayed(Duration(milliseconds: 500)); // ✅ Delay execution
        await roomController.deleteRoom(id);
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
        onPressed: () => showRoomDialog(),
        child: Icon(Icons.add,color: Colors.red,),
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
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: ListTile(
                    title: Text(room.roomName, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Room ID: ${room.id}\n${room.roomDesc}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => showRoomDialog(room: room)),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => confirmDelete(room.id!)),
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
                Get.snackbar("Export Successful", "PDF saved in documents folder!");
              },
              child: Text("Export Rooms as PDF"),
            ),
          ),
        ],
      )),
    );
  }
}
