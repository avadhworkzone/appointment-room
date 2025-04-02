// ignore_for_file: use_key_in_widget_constructors

import 'package:cal_room/screens/sales_report_screen.dart';
import 'package:cal_room/screens/transaction_report.dart';
import 'package:cal_room/utils/color_utils.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/user_controller.dart';
import '../controller/room_controller.dart';
import '../controller/reservation_controller.dart';
import '../database/db_helper.dart';
import '../controller/badge_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:get/get.dart';

import 'download_db.dart';
import 'login_screen.dart';
class SettingsScreen extends StatelessWidget {
  final isDarkMode = false.obs;
  final isLoading = false.obs; // ✅ Prevents multiple database operations at once

  final UserController userController = Get.find();
  final RoomController roomController = Get.find();
  final ReservationController reservationController = Get.find();
  final BadgeController badgeController = Get.find();

  /// Reset Specific Table or Entire Database
  void resetDatabase({String? table}) async {
    if (isLoading.value) return; // ✅ Prevent multiple clicks
    isLoading.value = true; // ✅ Start loading

    final db = await DBHelper.database;
    await db.transaction((txn) async {
      try {
        await txn.execute("PRAGMA foreign_keys = OFF;");

        if (table == StringUtils.users) {
          await txn.execute("DELETE FROM Users;");
          await userController.fetchUsers();
        } else if (table == StringUtils.rooms) {
          await txn.execute("DELETE FROM Rooms;");
          await roomController.fetchRooms();
        } else if (table == StringUtils.reservations) {
          await txn.execute("DELETE FROM Reservations;");
          await reservationController.fetchReservations();
        } else {
          await txn.execute("DELETE FROM Reservations;");
          await txn.execute("DELETE FROM Rooms;");
          await txn.execute("DELETE FROM Users;");
          await userController.fetchUsers();
          await roomController.fetchRooms();
          await reservationController.fetchReservations();
        }

        await txn.execute("PRAGMA foreign_keys = ON;");
      } catch (e) {
        Get.snackbar(StringUtils.error, "${StringUtils.dbResetFailed}: ${e.toString()}");
      }
    });

    // ✅ Update badge counts **AFTER** database operations are complete
    Future.delayed(Duration(milliseconds: 500), () {
      if (Get.isRegistered<BadgeController>()) {
        badgeController.updateBadgeCounts();
      }
    });

    isLoading.value = false; // ✅ Stop loading
    Get.snackbar(StringUtils.success, "${table ?? StringUtils.allData} ${StringUtils.resetSuccess}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(StringUtils.settings)),
      body: Column(
        children: [
          Obx(() => SwitchListTile(
            title: Text(StringUtils.darkMode),
            value: isDarkMode.value,
            onChanged: (value) {
              isDarkMode.value = value;
              Get.changeTheme(value ? ThemeData.dark() : ThemeData.light());
            },
          )),
          Obx(() {
            if (isLoading.value) {
              return Center(child: CircularProgressIndicator()); // ✅ Show loading indicator
            }
            return Column(
              children: [
                ListTile(
                  leading: Icon(Icons.delete, color: ColorUtils.red),
                  title: Text(StringUtils.resetAll),
                  onTap: () => showResetOptions(),
                ),
                ListTile(
                  leading: Icon(Icons.people, color: ColorUtils.blue),
                  title: Text(StringUtils.resetUsers),
                  onTap: () => resetDatabase(table: StringUtils.users),
                ),
                ListTile(
                  leading: Icon(Icons.meeting_room, color: ColorUtils.green),
                  title: Text(StringUtils.resetRooms),
                  onTap: () => resetDatabase(table: StringUtils.rooms),
                ),
                ListTile(
                  leading: Icon(Icons.event, color: ColorUtils.purple),
                  title: Text(StringUtils.resetReservations),
                  onTap: () => resetDatabase(table: StringUtils.reservations),
                ),
                ListTile(
                  leading: Icon(Icons.insert_drive_file_outlined, color: ColorUtils.blue),
                  title: Text(StringUtils.downloadDB),
                  onTap: () async{
                    await DownloadDBFile.downloadDBFile();

                  },
                ),
                ListTile(
                  leading: Icon(Icons.history, color: ColorUtils.blue),
                  title: Text(StringUtils.salesReport),
                  onTap: () async{
                    Get.to(()=>ReportScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.payment, color: ColorUtils.blue),
                  title: Text(StringUtils.transactionReport),
                  onTap: () async{
                    Get.to(()=>TransactionScreen());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: ColorUtils.red),
                  title: Text(StringUtils.logout),
                  onTap: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear(); // ✅ Remove login session

                    Get.off(() => LoginScreen()); // ✅ Navigate back to login
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// ✅ Show Confirmation Dialog Before Reset
  void showResetOptions() {
    Get.defaultDialog(
      title: StringUtils.resetDatabase,
      content: const Text(StringUtils.resetConfirmation),
      textCancel: StringUtils.cancel,
      textConfirm: StringUtils.confirmReset,
      confirmTextColor: ColorUtils.white,
      onConfirm: () {
        Get.back(); // Close dialog
        resetDatabase();
      },
    );
  }
}
