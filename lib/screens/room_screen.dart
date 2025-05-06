// import 'package:cal_room/utils/color_utils.dart';
// import 'package:cal_room/utils/string_utils.dart';
// import 'package:cal_room/widgets/add_edit_room_bottom_sheet.dart';
// import 'package:flutter/material.dart';
// import '../controller/room_controller.dart';
// import 'export_pdf.dart';
//
// class RoomScreen extends StatefulWidget {
//   const RoomScreen({super.key});
//   @override
//   State<RoomScreen> createState() => _RoomScreenState();
// }
//
// class _RoomScreenState extends State<RoomScreen> {
//   // final RoomController roomController = Get.find<RoomController>();
//   // ✅ Use Get.find() to avoid multiple instances
//   var isProcessing = false.obs;
//
//   void confirmDelete(int id) {
//     Get.defaultDialog(
//       title: StringUtils.deleteRoomTitle,
//       middleText: StringUtils.deleteRoomMessage,
//       textConfirm: StringUtils.delete,
//       textCancel: StringUtils.cancel,
//       confirmTextColor: ColorUtils.white,
//       onConfirm: () async {
//         isProcessing.value = true; // ✅ Prevent multiple clicks
//         await Future.delayed(Duration(milliseconds: 300)); // ✅ Delay execution
//         await roomController.deleteRoom(id);
//         await roomController.fetchRooms(); // ✅ Refresh list after delete
//         isProcessing.value = false;
//         Get.back();
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(StringUtils.rooms)),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => addEditRoomBottomSheet(context),
//         child: Icon(Icons.add),
//       ),
//       body: Obx(() => roomController.roomList.isEmpty
//           ? Center(child: Text(StringUtils.noRoomsFound))
//           : Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: roomController.roomList.length,
//                     itemBuilder: (context, index) {
//                       final room = roomController.roomList[index];
//                       return Card(
//                         elevation: 4,
//                         margin:
//                             EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                         child: ListTile(
//                           title: Text(room.roomName,
//                               style: TextStyle(fontWeight: FontWeight.bold)),
//                           // subtitle: Text("Room ID: ${room.id}\n${room.roomDesc}"),
//                           subtitle: Text(room.roomDesc),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                   icon:
//                                       Icon(Icons.edit, color: ColorUtils.blue),
//                                   onPressed: () => addEditRoomBottomSheet(
//                                       context,
//                                       room: room)),
//                               IconButton(
//                                   icon:
//                                       Icon(Icons.delete, color: ColorUtils.red),
//                                   onPressed: () => confirmDelete(room.id!)),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       exportRoomsAsPDF(roomController.roomList);
//                       Get.snackbar(
//                         StringUtils.exportSuccessTitle,
//                         StringUtils.exportRoomsSuccessMessage,
//                       );
//                     },
//                     child: Text(StringUtils.exportRooms),
//                   ),
//                 ),
//               ],
//             )),
//     );
//   }
// }
import 'package:cal_room/blocs/room/room_bloc.dart';
import 'package:cal_room/blocs/room/room_event.dart';
import 'package:cal_room/blocs/room/room_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:cal_room/widgets/add_edit_room_bottom_sheet.dart';
import 'export_pdf.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RoomBloc>().add(FetchRooms());
  }

  void confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(StringUtils.deleteRoomTitle),
        content: Text(StringUtils.deleteRoomMessage),
        actions: [
          TextButton(
            child: Text(StringUtils.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorUtils.red,
              foregroundColor: ColorUtils.white,
            ),
            child: Text(StringUtils.delete),
            onPressed: () {
              context.read<RoomBloc>().add(DeleteRoom(id));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(StringUtils.rooms)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addEditRoomBottomSheet(context),
        child: Icon(Icons.add),
      ),
      body: BlocBuilder<RoomBloc, RoomState>(
        builder: (context, state) {
          if (state is RoomLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is RoomLoaded) {
            if (state.rooms.isEmpty) {
              return Center(child: Text(StringUtils.noRoomsFound));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.rooms.length,
                    itemBuilder: (context, index) {
                      final room = state.rooms[index];
                      return Card(
                        elevation: 4,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        child: ListTile(
                          title: Text(
                            room.roomName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(room.roomDesc),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: ColorUtils.blue),
                                onPressed: () => addEditRoomBottomSheet(
                                  context,
                                  room: room,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: ColorUtils.red),
                                onPressed: () =>
                                    confirmDelete(context, room.id!),
                              ),
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
                      exportRoomsAsPDF(state.rooms);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(StringUtils.exportRoomsSuccessMessage),
                        ),
                      );
                    },
                    child: Text(StringUtils.exportRooms),
                  ),
                ),
              ],
            );
          } else if (state is RoomError) {
            return Center(child: Text(state.message));
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
