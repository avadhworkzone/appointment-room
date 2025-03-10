import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/user_controller.dart';
import '../model/user_model.dart';
import 'export_pdf.dart';

class UserScreen extends StatelessWidget {
  final UserController userController = Get.put(UserController());

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();

  void showUserDialog({UserModel? user}) {
    if (user != null) {
      usernameController.text = user.username;
      passwordController.text = user.password;
      fullnameController.text = user.fullname;
    } else {
      usernameController.clear();
      passwordController.clear();
      fullnameController.clear();
    }

    Get.defaultDialog(
      title: user == null ? "Add User" : "Edit User",
      content: Column(
        children: [
          TextField(controller: usernameController, decoration: InputDecoration(labelText: "Username")),
          TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
          TextField(controller: fullnameController, decoration: InputDecoration(labelText: "Full Name")),
        ],
      ),
      textConfirm: user == null ? "Add" : "Update",
      textCancel: "Cancel",
      onConfirm: () {
        if (usernameController.text.isEmpty || fullnameController.text.isEmpty) {
          Get.snackbar("Error", "Username and Full Name are required");
          return;
        }

        if (user == null) {
          userController.addUser(UserModel(
            username: usernameController.text,
            password: passwordController.text,
            fullname: fullnameController.text,
          ));
        } else {
          userController.updateUser(UserModel(
            id: user.id,
            username: usernameController.text,
            password: passwordController.text,
            fullname: fullnameController.text,
          ));
        }
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: userController.userList.length,
                itemBuilder: (context, index) {
                  final user = userController.userList[index];
                  return ListTile(
                    title: Text(user.fullname),
                    subtitle: Text("Username: ${user.username}"),
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
        );
      }),
    );
  }
}
