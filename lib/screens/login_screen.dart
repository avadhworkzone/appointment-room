// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cal_room/blocs/login/login_bloc.dart';
import 'package:cal_room/blocs/login/login_event.dart';
import 'package:cal_room/blocs/login/login_state.dart';
import 'package:cal_room/blocs/signup/signup_bloc.dart';
import 'package:cal_room/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'main_screen.dart';
import 'signup_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final UserController userController =
//       Get.find<UserController>(); // ✅ Use singleton instance
//   var isProcessing = false.obs; // ✅ Prevent multiple clicks
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   /// ✅ **Login Logic**
//   void _login() async {
//     if (_formKey.currentState!.validate()) {
//       isProcessing.value = true;
//
//       await userController.loginFetchUsers(); // ✅ Fetch users from DB
//       String username = usernameController.text.trim();
//       String password = passwordController.text.trim();
//
//       var user = userController.loginUserList.firstWhereOrNull(
//         (user) => user.username == username && user.password == password,
//       );
//
//       if (user != null) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('isLoggedIn', true); // ✅ Save login session
//         await prefs.setString(
//             'userId',
//             userController.loginUserList.first.id
//                 .toString()); // ✅ Save login session
//         await prefs.setString('username', username);
//
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(StringUtils.loginSuccess)));
//         Get.off(() => MainScreen()); // ✅ Navigate to Home
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(StringUtils.invalidCredentials)));
//       }
//
//       isProcessing.value = false;
//     }
//   }
//
//   InputDecoration _inputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       border: OutlineInputBorder(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(StringUtils.login)),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset('assets/logo.jpg', height: 200),
//                   // ✅ Replace with your logo
//                   SizedBox(
//                     height: 50,
//                   ),
//                   TextFormField(
//                     controller: usernameController,
//                     decoration: _inputDecoration("Username"),
//                     validator: (value) =>
//                         value!.isEmpty ? StringUtils.enterUsername : null,
//                   ),
//                   SizedBox(height: 10),
//                   TextFormField(
//                     controller: passwordController,
//                     decoration: _inputDecoration("Password"),
//                     obscureText: true,
//                     validator: (value) =>
//                         value!.length < 6 ? StringUtils.passwordTooShort : null,
//                   ),
//                   SizedBox(height: 20),
//                   Obx(() => isProcessing.value
//                       ? CircularProgressIndicator()
//                       : ElevatedButton(
//                           onPressed: _login, child: Text(StringUtils.login))),
//                   // TextButton(
//                   //   onPressed: () => Get.off(() => SignupScreen()),
//                   //   // ✅ GetX navigation
//                   //   child: Text(StringUtils.signupRedirect),
//                   // ),
//                   TextButton(
//                     onPressed: () {
//                       Get.off(() => BlocProvider(
//                             create: (_) => SignupBloc(),
//                             child: const SignupScreen(),
//                           ));
//                     },
//                     child: Text(StringUtils.signupRedirect),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

/// login bloc
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: Scaffold(
        appBar: AppBar(title: Text(StringUtils.login)),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state is LoginSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(StringUtils.loginSuccess)));
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                } else if (state is LoginFailure) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Image.asset('assets/logo.jpg', height: 200),
                        SizedBox(height: 50),
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                              labelText: "Username",
                              border: OutlineInputBorder()),
                          validator: (value) =>
                              value!.isEmpty ? StringUtils.enterUsername : null,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder()),
                          obscureText: true,
                          validator: (value) => value!.length < 6
                              ? StringUtils.passwordTooShort
                              : null,
                        ),
                        SizedBox(height: 20),
                        state is LoginLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    context
                                        .read<LoginBloc>()
                                        .add(LoginSubmitted(
                                          username:
                                              usernameController.text.trim(),
                                          password:
                                              passwordController.text.trim(),
                                        ));
                                  }
                                },
                                child: Text(StringUtils.login),
                              ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (_) => SignupBloc(),
                                  child: const SignupScreen(),
                                ),
                              ),
                            );
                          },
                          child: Text(StringUtils.signupRedirect),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
