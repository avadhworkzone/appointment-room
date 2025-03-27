// ✅ Prevent multiple clicks and database locks
import 'dart:developer';

import 'package:cal_room/controller/room_controller.dart';
import 'package:cal_room/model/room_model.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void addEditRoomBottomSheet({RoomModel? room}) {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController roomDescController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var isProcessing = false.obs;
  final RoomController roomController = Get.find<RoomController>();

  if (room != null) {
    roomNameController.text = room.roomName;
    roomDescController.text = room.roomDesc;
  } else {
    roomNameController.clear();
    roomDescController.clear();
  }

  Get.bottomSheet(
    Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(room == null ? StringUtils.addRoom : StringUtils.editRoom,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextFormField(
              controller: roomNameController,
              validator: (value) => value!.isEmpty ? StringUtils.enterRoomName : null,
              decoration: InputDecoration(
                labelText: StringUtils.roomName,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
                controller: roomDescController,
                // validator: (value) =>
                // value!.isEmpty ? "Enter room description" : null,
                decoration: InputDecoration(
                  labelText: StringUtils.roomDescription,
                  border: OutlineInputBorder(),
                )),
            SizedBox(height: 20),
            Obx(() => ElevatedButton(
                  onPressed: isProcessing.value
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            if (roomNameController.text.isEmpty) {
                              Get.snackbar(StringUtils.error, StringUtils.roomNameRequired,);
                              return;
                            }

                            isProcessing.value =
                                true; // ✅ Prevent multiple clicks
                            // await Future.delayed(Duration(milliseconds: 300)); // ✅ Ensure previous writes finish
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            var userId = prefs.getString('userId') ?? "";
                            log('user id ---> $userId');
                            if (room == null) {
                              await roomController.addRoom(RoomModel(
                                roomName: roomNameController.text,
                                roomDesc: roomDescController.text,
                                userId: int.parse(userId),
                              ));
                            } else {
                              await roomController.updateRoom(RoomModel(
                                id: room.id,
                                roomName: roomNameController.text,
                                roomDesc: roomDescController.text,
                                userId: int.parse(userId),
                              ));
                            }

                            await roomController
                                .fetchRooms(); // ✅ Update list immediately
                            isProcessing.value = false;
                            Get.back();
                          }
                        },
                  child: Text(room == null ?  StringUtils.addRoom
                    : StringUtils.updateRoom,),
                )),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
