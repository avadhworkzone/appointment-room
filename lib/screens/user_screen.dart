// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors_in_immutables

import 'dart:developer';

import 'package:cal_room/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/user_controller.dart';
import '../model/user_model.dart';
import 'export_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserScreen extends StatefulWidget {

  UserScreen({super.key});
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserController userController = Get.find<UserController>();
 // ✅ Use Get.find() to avoid multiple instances
  final TextEditingController mobileController = TextEditingController();

  final TextEditingController fullnameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  var isProcessing = false.obs;

 // ✅ Prevent multiple clicks and database locks
  void showUserDialog({UserModel? user}) {
    if (user != null) {
      mobileController.text = user.mobileNumber;
      fullnameController.text = user.fullname;
    } else {
      mobileController.clear();
      fullnameController.clear();
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user == null ?  StringUtils.addUser
                  : StringUtils.editUser,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Full Name Field with Validation
                TextFormField(
                  controller: fullnameController,
                  validator: (value) =>
                  value!.isEmpty ? StringUtils.enterName : null,
                  decoration: InputDecoration(
                    labelText: StringUtils.fullName,
                    border: OutlineInputBorder(), // ✅ Outline Border
                    prefixIcon: Icon(Icons.person), // ✅ Icon for better UI
                  ),
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: 10),

                // Mobile Number Field with Validation
                TextFormField(
                  controller: mobileController,
                  validator: (value) {
                      if(value!.isEmpty){
                        return StringUtils.enterMobileNumber;
                      }
                     else if(value.length < 10 ||value.length > 10){
                      return StringUtils.invalidPhoneNumber;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: StringUtils.mobileNumber,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10, // ✅ Limit to 10 digits
                ),
                SizedBox(height: 10),

                Obx(() => ElevatedButton(
                  onPressed: isProcessing.value
                      ? null
                      : () async {
                    if(_formKey.currentState!.validate()){
                      // ✅ Validation
                      String mobilePattern = r'^[0-9]{10}$'; // Only 10-digit numbers
                      RegExp regExp = RegExp(mobilePattern);

                      if (fullnameController.text.trim().isEmpty) {
                        Get.snackbar(StringUtils.error, StringUtils.fullNameValidation);
                        return;
                      }
                      if (!regExp.hasMatch(mobileController.text.trim())) {
                        Get.snackbar(StringUtils.error, StringUtils.validPhoneWarning);
                        return;
                      }

                      isProcessing.value = true; // ✅ Prevent multiple clicks
                      await Future.delayed(Duration(milliseconds: 300)); // ✅ Ensure previous writes finish

                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      var userId = prefs.getString('userId') ?? "";
                      log('user id ---> $userId');

                      if (user == null) {
                        await userController.addUser(UserModel(
                          mobileNumber: mobileController.text.trim(),
                          userId: userId,
                          fullname: fullnameController.text.trim(),
                        ));
                      } else {
                        await userController.updateUser(UserModel(
                          id: user.id,
                          userId: userId,
                          mobileNumber: mobileController.text.trim(),
                          fullname: fullnameController.text.trim(),
                        ));
                      }

                      await userController.fetchUsers(); // ✅ Update list immediately
                      isProcessing.value = false;
                      Get.back();
                    }

                  },
                  child: Text(user == null ?  StringUtils.addUser
                      : StringUtils.updateUser),
                )),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void confirmDelete(int id) {
    Get.defaultDialog(
      title: StringUtils.deleteUserTitle,
      middleText: StringUtils.deleteUserMessage,
      textConfirm: StringUtils.delete,
      textCancel: StringUtils.cancel,
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
      appBar: AppBar(title: Text(StringUtils.users)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showUserDialog(),
        child: Icon(Icons.add),
      ),
      body: Obx(() => userController.userList.isEmpty
          ? Center(child: Text(StringUtils.noUsersFound))
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
                    subtitle: Text("${StringUtils.mobileNumber}: ${user.mobileNumber}"),
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
                Get.snackbar(StringUtils.exportSuccessTitle,
                    StringUtils.exportSuccessMessage);
              },
              child: Text(StringUtils.exportUsers),
            ),
          ),
        ],
      )),
    );
  }
}
