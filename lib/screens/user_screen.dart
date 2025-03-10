import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/user_controller.dart';
import '../model/user_model.dart';
import 'export_pdf.dart';

class UserScreen extends StatelessWidget {
  final UserController userController = Get.find<UserController>(); // ✅ Use Get.find() to avoid multiple instances

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();

  var isProcessing = false.obs; // ✅ Prevent multiple clicks and database locks

  void showUserDialog({UserModel? user}) {
    if (user != null) {
      usernameController.text = user.username;
      fullnameController.text = user.fullname;
    } else {
      usernameController.clear();
      fullnameController.clear();
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
            Text(user == null ? "Add User" : "Edit User",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: usernameController, decoration: InputDecoration(labelText: "Username")),
            TextField(controller: fullnameController, decoration: InputDecoration(labelText: "Full Name")),
            SizedBox(height: 10),
            Obx(() => ElevatedButton(
              onPressed: isProcessing.value
                  ? null
                  : () async {
                if (usernameController.text.isEmpty || fullnameController.text.isEmpty) {
                  Get.snackbar("Error", "Username and Full Name are required");
                  return;
                }

                isProcessing.value = true; // ✅ Prevent multiple clicks
                await Future.delayed(Duration(milliseconds: 300)); // ✅ Ensure previous writes finish

                if (user == null) {
                  await userController.addUser(UserModel(
                    username: usernameController.text,
                    fullname: fullnameController.text,
                  ));
                } else {
                  await userController.updateUser(UserModel(
                    id: user.id,
                    username: usernameController.text,
                    fullname: fullnameController.text,
                  ));
                }

                await userController.fetchUsers(); // ✅ Update list immediately
                isProcessing.value = false;
                Get.back();
              },
              child: Text(user == null ? "Add User" : "Update User"),
            )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void confirmDelete(int id) {
    Get.defaultDialog(
      title: "Delete User",
      middleText: "Are you sure you want to delete this user?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        isProcessing.value = true; // ✅ Prevent multiple clicks
        await Future.delayed(Duration(milliseconds: 300)); // ✅ Delay execution
        await userController.deleteUser(id);
        await userController.fetchUsers(); // ✅ Refresh user list after delete
        isProcessing.value = false;
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showUserDialog(),
        child: Icon(Icons.add),
      ),
      body: Obx(() => userController.userList.isEmpty
          ? Center(child: Text("No users found. Add a new user!"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: userController.userList.length,
              itemBuilder: (context, index) {
                final user = userController.userList[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: ListTile(
                    title: Text(user.fullname, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Username: ${user.username}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => showUserDialog(user: user)),
                        IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => confirmDelete(user.id!)),
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
                exportUsersAsPDF(userController.userList);
                Get.snackbar("Export Successful", "PDF saved in documents folder!");
              },
              child: Text("Export Users as PDF"),
            ),
          ),
        ],
      )),
    );
  }
}
