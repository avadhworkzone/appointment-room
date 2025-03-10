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

    Get.defaultDialog(
      title: room == null ? "Add Room" : "Edit Room",
      content: Column(
        children: [
          TextField(controller: roomNameController, decoration: InputDecoration(labelText: "Room Name")),
          TextField(controller: roomDescController, decoration: InputDecoration(labelText: "Room Description")),
          TextField(controller: userIdController, decoration: InputDecoration(labelText: "User ID"), keyboardType: TextInputType.number),
        ],
      ),
      textConfirm: room == null ? "Add" : "Update",
      textCancel: "Cancel",
      onConfirm: () {
        if (roomNameController.text.isEmpty || userIdController.text.isEmpty) {
          Get.snackbar("Error", "Room Name and User ID are required");
          return;
        }

        if (room == null) {
          roomController.addRoom(RoomModel(
            roomName: roomNameController.text,
            roomDesc: roomDescController.text,
            userId: int.parse(userIdController.text),
          ));
        } else {
          roomController.updateRoom(RoomModel(
            id: room.id,
            roomName: roomNameController.text,
            roomDesc: roomDescController.text,
            userId: int.parse(userIdController.text),
          ));
        }
        Get.back();
      },
    );
  }

  void confirmDelete(int id) {
    Get.defaultDialog(
      title: "Delete Room",
      middleText: "Are you sure you want to delete this room?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        roomController.deleteRoom(id);
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
        child: Icon(Icons.add),
      ),
      body: Obx(() {

        return Column(
          children: [
            Expanded(
              child: roomController.roomList.isEmpty?Center(child: Text("No rooms found. Add a new room!")):ListView.builder(
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
        );
      }),
    );
  }
}
