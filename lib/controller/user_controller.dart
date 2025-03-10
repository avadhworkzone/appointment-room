import 'package:get/get.dart';
import '../database/db_helper.dart';
import '../model/user_model.dart';

class UserController extends GetxController {
  var userList = <UserModel>[].obs;
  var isProcessing = false.obs; // ✅ Prevents multiple simultaneous operations

  @override
  void onInit() {
    super.onInit();
    fetchUsers(); // ✅ Load users when the controller is initialized
  }

  /// ✅ **Optimized Fetch Method**
  fetchUsers() async {
    if (isProcessing.value) return; // ✅ Prevents multiple fetches at once
    isProcessing.value = true;

    final users = await DBHelper.getUsers();
    userList.assignAll(users.map((e) => UserModel.fromMap(e)).toList());

    isProcessing.value = false;
  }

  /// ✅ **Transaction-Based Insert**
  Future<void> addUser(UserModel user) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.insert('Users', user.toMap());
      });
    });

    await fetchUsers(); // ✅ Refresh list after adding a user
    isProcessing.value = false;
  }

  /// ✅ **Transaction-Based Update**
  Future<void> updateUser(UserModel user) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.update('Users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
      });
    });

    await fetchUsers(); // ✅ Refresh list after updating a user
    isProcessing.value = false;
  }

  /// ✅ **Transaction-Based Delete**
  Future<void> deleteUser(int id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.delete('Users', where: 'id = ?', whereArgs: [id]);
      });
    });

    await fetchUsers(); // ✅ Refresh list after deleting a user
    isProcessing.value = false;
  }
}
