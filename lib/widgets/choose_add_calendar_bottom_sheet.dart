import 'package:cal_room/utils/string_utils.dart' show StringUtils;
import 'package:cal_room/widgets/add_edit_reservation_bottom_sheet.dart';
import 'package:cal_room/widgets/add_edit_room_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void chooseAddCalendarBottomSheet(){
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
          Text(StringUtils.addTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),

          ListTile(
            onTap: () {
              Get.back();
              addEditReservationBottomSheet();
            },
            title: Text(StringUtils.reservation),
            leading: Icon(Icons.add),
          ),
          ListTile(
            onTap: () {
              Get.back();
              addEditRoomBottomSheet();
            },
            title: Text(StringUtils.room),
            leading: Icon(Icons.bedroom_parent_outlined),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );

}