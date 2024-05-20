import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_employee/GlobalComponents/button_global.dart';
import 'package:hrm_employee/constant.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../GlobalComponents/button_global.dart';
import '../../main.dart';
import '../../providers/user_provider.dart';
import '../Home/home_screen.dart';
import 'forgot_password.dart';
import 'sign_up.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController userIDController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    checkLoggedIn(); // Check if user is already logged in on screen initialization
  }

  Future<void> checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      // User is already logged in, navigate to home screen
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  Future<void> signIn() async {
    String hashedPassword = passwordController.text;
    String userID = userIDController.text;

    var response = await http.post(
      Uri.parse('http://192.168.1.116:3000/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userID': userID,
        'password': hashedPassword,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      String token = responseData['token'];
      String userID = responseData['userID'];
      await storeUserData(token, userID);

      UserData userData = context.read<UserData>();
      userData.setUserData(token, userID);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      print('Login failed');
    }
  }

  Future<void> storeUserData(String token, String userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userID', userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      // appBar: AppBar(
      //   backgroundColor: kMainColor,
      //   elevation: 0.0,
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   title: Text(
      //     'Sign In',
      //     style: kTextStyle.copyWith(
      //       color: Colors.white,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
      body: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 35.0, left: 20.0, right: 20.0, bottom: 20.0),
              // child: Text(
              //   'Welcome to SmartH2R',
              //   style: kTextStyle.copyWith(color: Colors.white),
              // ),
              child: Image.asset('images/Smart H2R_2.png',
                  width: 200), // Your image goes here
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(200.0),
                  ),
                  color: Colors.white,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      right: 5,
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome ',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 55, 145, 214),
                                  fontSize: 20),
                            ),
                            TextSpan(
                                text: 'to ',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 238, 162, 53),
                                    fontSize: 20)),
                            TextSpan(
                                text: 'SmartH2R',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 55, 145, 214),
                                    fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20.0,
                        ),
                        SizedBox(
                          height: 60.0,
                          child: TextField(
                            controller: userIDController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              labelText: 'User ID',
                              hintText: 'Enter your User ID',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your Password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                value: isChecked,
                                activeColor: Colors.blue,
                                onChanged: (bool value) {
                                  setState(() {
                                    isChecked = value;
                                  });
                                },
                              ),
                            ),
                            const Text('Save Me'),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        ButtonGlobal(
                          buttontext: 'Sign In',
                          buttonDecoration: kButtonDecoration.copyWith(
                              color: const Color.fromARGB(255, 238, 162, 53)),
                          onPressed: () {
                            signIn();
                          },
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?"),
                            GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignUp(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  ' Sign Up',
                                  style: TextStyle(color: Colors.blue),
                                )),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
