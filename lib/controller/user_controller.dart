import 'package:get/get.dart';

import '../database/db_helper.dart';
import '../model/user_model.dart';

class UserController extends GetxController {
  var userList = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

   fetchUsers() async {
    final users = await DBHelper.getUsers();
    userList.value = users.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<void> addUser(UserModel user) async {
    await DBHelper.insertUser(user.toMap());
    fetchUsers();
  }

  Future<void> updateUser(UserModel user) async {
    await DBHelper.updateUser(user.toMap(), user.id!);
    fetchUsers();
  }

  Future<void> deleteUser(int id) async {
    await DBHelper.deleteUser(id);
    fetchUsers();
  }
}
