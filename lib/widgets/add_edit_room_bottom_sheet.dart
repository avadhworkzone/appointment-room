// import 'dart:developer';
// import 'package:cal_room/model/room_model.dart';
// import 'package:cal_room/utils/color_utils.dart';
// import 'package:cal_room/utils/string_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void addEditRoomBottomSheet(BuildContext context, {RoomModel? room}) {
//   final TextEditingController roomNameController = TextEditingController();
//   final TextEditingController roomDescController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   final ValueNotifier<bool> isProcessing = ValueNotifier(false);
//
//   if (room != null) {
//     roomNameController.text = room.roomName;
//     roomDescController.text = room.roomDesc;
//   }
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) {
//       return Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//           left: 16,
//           right: 16,
//           top: 16,
//         ),
//         child: Form(
//           key: formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 room == null ? StringUtils.addRoom : StringUtils.editRoom,
//                 style:
//                     const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: roomNameController,
//                 validator: (value) =>
//                     value!.isEmpty ? StringUtils.enterRoomName : null,
//                 decoration: const InputDecoration(
//                   labelText: StringUtils.roomName,
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: roomDescController,
//                 decoration: const InputDecoration(
//                   labelText: StringUtils.roomDescription,
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ValueListenableBuilder<bool>(
//                 valueListenable: isProcessing,
//                 builder: (context, processing, _) {
//                   return ElevatedButton(
//                     onPressed: processing
//                         ? null
//                         : () async {
//                             if (formKey.currentState!.validate()) {
//                               if (roomNameController.text.isEmpty) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(StringUtils.roomNameRequired),
//                                     backgroundColor: ColorUtils.blue,
//                                   ),
//                                 );
//                                 return;
//                               }
//
//                               isProcessing.value = true;
//
//                               SharedPreferences prefs =
//                                   await SharedPreferences.getInstance();
//                               final userId = prefs.getString('userId') ?? "";
//                               log('user id ---> $userId');
//
//                               if (room == null) {
//                                 await roomController.addRoom(RoomModel(
//                                   roomName: roomNameController.text,
//                                   roomDesc: roomDescController.text,
//                                   userId: int.parse(userId),
//                                 ));
//                               } else {
//                                 await roomController.updateRoom(RoomModel(
//                                   id: room.id,
//                                   roomName: roomNameController.text,
//                                   roomDesc: roomDescController.text,
//                                   userId: int.parse(userId),
//                                 ));
//                               }
//
//                               await roomController.fetchRooms();
//                               isProcessing.value = false;
//                               Navigator.pop(context);
//                             }
//                           },
//                     child: Text(room == null
//                         ? StringUtils.addRoom
//                         : StringUtils.updateRoom),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cal_room/blocs/room/room_bloc.dart';
import 'package:cal_room/blocs/room/room_event.dart';
import 'package:cal_room/model/room_model.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void addEditRoomBottomSheet(BuildContext context, {RoomModel? room}) {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController roomDescController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> isProcessing = ValueNotifier(false);

  if (room != null) {
    roomNameController.text = room.roomName;
    roomDescController.text = room.roomDesc;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                room == null ? StringUtils.addRoom : StringUtils.editRoom,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: roomNameController,
                validator: (value) =>
                    value!.isEmpty ? StringUtils.enterRoomName : null,
                decoration: const InputDecoration(
                  labelText: StringUtils.roomName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: roomDescController,
                decoration: const InputDecoration(
                  labelText: StringUtils.roomDescription,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: isProcessing,
                builder: (context, processing, _) {
                  return ElevatedButton(
                    onPressed: processing
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              if (roomNameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(StringUtils.roomNameRequired),
                                    backgroundColor: ColorUtils.blue,
                                  ),
                                );
                                return;
                              }

                              isProcessing.value = true;

                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              final userId = prefs.getString('userId') ?? "";
                              log('user id ---> $userId');

                              final bloc = BlocProvider.of<RoomBloc>(context);

                              if (room == null) {
                                bloc.add(AddRoom(
                                  RoomModel(
                                    roomName: roomNameController.text,
                                    roomDesc: roomDescController.text,
                                    userId: int.parse(userId),
                                  ),
                                ));
                              } else {
                                bloc.add(UpdateRoom(
                                  RoomModel(
                                    id: room.id,
                                    roomName: roomNameController.text,
                                    roomDesc: roomDescController.text,
                                    userId: int.parse(userId),
                                  ),
                                ));
                              }

                              // Let the bloc handle the fetching and updating
                              isProcessing.value = false;
                              Navigator.pop(context);
                            }
                          },
                    child: Text(room == null
                        ? StringUtils.addRoom
                        : StringUtils.updateRoom),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
