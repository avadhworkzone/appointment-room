import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/user_controller.dart';
import '../controller/room_controller.dart';
import '../controller/reservation_controller.dart';
import '../database/db_helper.dart';
import '../controller/badge_controller.dart';

class SettingsScreen extends StatelessWidget {
  final isDarkMode = false.obs;
  final isLoading = false.obs; // Track loading state

  final UserController userController = Get.find();
  final RoomController roomController = Get.find();
  final ReservationController reservationController = Get.find();
  final BadgeController badgeController = Get.find();

  /// Reset Specific Table or Entire Database
  void resetDatabase({String? table}) async {
    final db = await DBHelper.database;
    final BadgeController badgeController = Get.find(); // ✅ Ensure it's available
    isLoading.value = true; // Start loading

    await db.transaction((txn) async {
      await txn.execute("PRAGMA foreign_keys = OFF;");

      if (table == "Users") {
        await txn.execute("DELETE FROM Users;");
        userController.fetchUsers();
      } else if (table == "Rooms") {
        await txn.execute("DELETE FROM Rooms;");
        roomController.fetchRooms();
      } else if (table == "Reservations") {
        await txn.execute("DELETE FROM Reservations;");
        reservationController.fetchReservations();
      } else {
        await txn.execute("DELETE FROM Reservations;");
        await txn.execute("DELETE FROM Rooms;");
        await txn.execute("DELETE FROM Users;");
        userController.fetchUsers();
        roomController.fetchRooms();
        reservationController.fetchReservations();
      }

      await txn.execute("PRAGMA foreign_keys = ON;");
    });

    // Update badge counts
    if (Get.isRegistered<BadgeController>()) {
      badgeController.updateBadgeCounts();
    }

    isLoading.value = false; // Stop loading
    Get.snackbar("Success", "${table ?? 'All Data'} reset successfully!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Column(
        children: [
          Obx(() => SwitchListTile(
            title: Text("Dark Mode"),
            value: isDarkMode.value,
            onChanged: (value) {
              isDarkMode.value = value;
              Get.changeTheme(value ? ThemeData.dark() : ThemeData.light());
            },
          )),
          Obx(() {
            if (isLoading.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              children: [
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text("Reset Entire Database"),
                  onTap: () => showResetOptions(),
                ),
                ListTile(
                  leading: Icon(Icons.people, color: Colors.blue),
                  title: Text("Reset Users"),
                  onTap: () => resetDatabase(table: "Users"),
                ),
                ListTile(
                  leading: Icon(Icons.meeting_room, color: Colors.green),
                  title: Text("Reset Rooms"),
                  onTap: () => resetDatabase(table: "Rooms"),
                ),
                ListTile(
                  leading: Icon(Icons.event, color: Colors.purple),
                  title: Text("Reset Reservations"),
                  onTap: () => resetDatabase(table: "Reservations"),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Show Confirmation Dialog Before Reset
  void showResetOptions() {
    Get.defaultDialog(
      title: "Reset Database",
      content: Text("Are you sure you want to delete all data?"),
      textCancel: "Cancel",
      textConfirm: "Yes, Reset",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Close dialog
        resetDatabase();
      },
    );
  }
}
