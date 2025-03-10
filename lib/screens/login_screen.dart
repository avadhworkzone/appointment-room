import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/user_controller.dart';
import 'main_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserController userController = Get.find<UserController>(); // ✅ Use singleton instance
  var isProcessing = false.obs; // ✅ Prevent multiple clicks

  @override
  void initState() {
    super.initState();
  }


  /// ✅ **Login Logic**
  void _login() async {
    if (_formKey.currentState!.validate()) {
      isProcessing.value = true;

      await userController.loginFetchUsers(); // ✅ Fetch users from DB
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      var user = userController.loginUserList.firstWhereOrNull(
            (user) => user.username == username && user.password == password,
      );

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true); // ✅ Save login session
        await prefs.setString('userId', userController.loginUserList.first.id.toString()); // ✅ Save login session
        await prefs.setString('username', username);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Successful!")));
        Get.off(() => MainScreen()); // ✅ Navigate to Home
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid Credentials!")));
      }

      isProcessing.value = false;
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
      appBar: AppBar(title: Text("Login")),
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
                    decoration: _inputDecoration("Username"),
                    validator: (value) => value!.isEmpty ? "Enter username" : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    decoration: _inputDecoration("Password"),
                    obscureText: true,
                    validator: (value) => value!.length < 6 ? "Password must be 6+ chars" : null,
                  ),
                  SizedBox(height: 20),
                  Obx(() => isProcessing.value
                      ? CircularProgressIndicator()
                      : ElevatedButton(onPressed: _login, child: Text("Login"))),
                  TextButton(
                    onPressed: () => Get.off(() => SignupScreen()), // ✅ GetX navigation
                    child: Text("Don't have an account? Signup"),
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
