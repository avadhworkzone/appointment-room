// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cal_room/utils/string_utils.dart';
import 'package:flutter/material.dart';
import '../controller/user_controller.dart';
// import '../database/db_helper.dart';
import '../model/login_user_model.dart';
// import '../model/user_model.dart';
import 'login_screen.dart';
import 'package:get/get.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final UserController userController = Get.find<UserController>(); // ✅ Use Get.find() to avoid multiple instances
  var isProcessing = false.obs; // ✅ Prevent multiple clicks and database locks

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      isProcessing.value = true; // ✅ Prevent multiple clicks

      // await DBHelper.insertUser();

      await userController.addLoginUser(LoginUserModel(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        fullname: fullnameController.text.trim(),
      ));
      isProcessing.value = false;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Successful!")));

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(StringUtils.signup)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.jpg', height: 200), // ✅ Replace with your logo
                  SizedBox(height: 50,),
                  TextFormField(
                    controller: usernameController,
                    decoration: _inputDecoration(StringUtils.username),
                    validator: (value) => value!.isEmpty ? StringUtils.enterUsername : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    decoration: _inputDecoration(StringUtils.password),
                    obscureText: true,
                    validator: (value) => value!.length < 6 ? StringUtils.passwordTooShort : null,
                  ),
                  SizedBox(height: 10),

                  TextFormField(
                    controller: fullnameController,
                    decoration: _inputDecoration(StringUtils.fullName),
                    obscureText: false,
                    validator: (value) => value!.isEmpty ? StringUtils.enterFullName : null,
                  ),
                  SizedBox(height: 20),
                  isProcessing.value?CircularProgressIndicator():   ElevatedButton(onPressed:  isProcessing.value
                      ? null
                      :_signup, child: Text(StringUtils.signup)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())),
                    child: Text(StringUtils.loginRedirect),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
