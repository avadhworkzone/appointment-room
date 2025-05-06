import 'package:cal_room/database/db_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/login_user_model.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      // 👇 Moved logic from loginFetchUsers()
      final users = await DBHelper.getLoginUsers();
      final loginUserList =
          users.map((e) => LoginUserModel.fromMap(e)).toList();

      // 👇 Login check
      final user = loginUserList.firstWhereOrNull(
        (u) => u.username == event.username && u.password == event.password,
      );

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', user.id.toString());
        await prefs.setString('username', user.username);
        emit(LoginSuccess());
      } else {
        emit(LoginFailure("Invalid username or password"));
      }
    } catch (e) {
      emit(LoginFailure("An error occurred during login"));
    }
  }
}
