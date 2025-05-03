import 'package:cal_room/database/db_helper.dart';
import 'package:cal_room/model/login_user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(SignupInitial()) {
    on<SignupSubmitted>(_onSignupSubmitted);
  }

  Future<void> _onSignupSubmitted(
      SignupSubmitted event, Emitter<SignupState> emit) async {
    emit(SignupLoading());

    try {
      final user = LoginUserModel(
        username: event.username.trim(),
        password: event.password.trim(),
        fullname: event.fullname.trim(),
      );

      final db = await DBHelper.database;
      await db.transaction((txn) async {
        await txn.insert('LoginUsers', user.toMap());
      });

      emit(SignupSuccess());
    } catch (e) {
      emit(SignupFailure('Signup failed: ${e.toString()}'));
    }
  }
}
