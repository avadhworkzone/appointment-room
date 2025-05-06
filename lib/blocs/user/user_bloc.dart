// user_bloc.dart
import 'package:cal_room/blocs/user/user_event.dart';
import 'package:cal_room/blocs/user/user_state.dart';
import 'package:cal_room/database/db_helper.dart';
import 'package:cal_room/model/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await DBHelper.getUsers();
      final userList = users.map((e) => UserModel.fromMap(e)).toList();
      emit(UserLoaded(userList));
    } catch (_) {
      emit(UserError("Failed to fetch users"));
    }
  }

  Future<void> _onAddUser(AddUser event, Emitter<UserState> emit) async {
    await DBHelper.database.then((db) async {
      await db.transaction((txn) async {
        await txn.insert('Users', event.user.toMap());
      });
    });

    final users = await DBHelper.getUsers();
    final userModels = users.map((e) => UserModel.fromMap(e)).toList();
    emit(UserLoaded(userModels));
    add(FetchUsers());
  }

  // Future<void> _onAddUser(AddUser event, Emitter<UserState> emit) async {
  //   try {
  //     final db = await DBHelper.database;
  //     await db.transaction((txn) async {
  //       await txn.insert('Users', event.user.toMap());
  //     });
  //     add(FetchUsers());
  //   } catch (_) {
  //     emit(UserError("Failed to add user"));
  //   }
  // }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    try {
      final db = await DBHelper.database;
      await db.transaction((txn) async {
        await txn.update('Users', event.user.toMap(),
            where: 'id = ?', whereArgs: [event.user.id]);
      });
      add(FetchUsers());
    } catch (_) {
      emit(UserError("Failed to update user"));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    try {
      final db = await DBHelper.database;
      await db.delete('Users', where: 'id = ?', whereArgs: [event.id]);
      add(FetchUsers());
    } catch (_) {
      emit(UserError("Failed to delete user"));
    }
  }
}
