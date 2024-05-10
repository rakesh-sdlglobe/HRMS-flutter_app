import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hrm_employee/Screens/Authentication/sign_up.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/button_global.dart';
import '../../constant.dart';
import 'forgot_password.dart';
import '../Home/home_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;
  bool isLoading = false;

  // Function to check if the user is already logged in
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Function to handle user login
  Future<void> loginUser() async {
    // Check if already loading
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final String apiUrl =
        'https://flutter-shopwise-app.onrender.com/user-login';

    final Map<String, dynamic> data = {
      'email': emailController.text,
      'password': passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['accessToken'] != null) {
          print('Login successful!');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', responseData['accessToken']);
          await prefs.setBool('isLoggedIn', true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          print('Invalid credentials');
          _showErrorDialog('Invalid credentials');
        }
      } else {
        print('Failed to login. Status code: ${response.statusCode}');
        _showErrorDialog('Failed to login. Please try again later.');
      }
    } catch (error) {
      print('Error during user login: $error');
      _showErrorDialog('An unexpected error occurred. Please try again later.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to show error dialog
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Check login status when the sign-in screen loads
    checkLoginStatus().then((isLoggedIn) {
      if (isLoggedIn) {
        // If already logged in, navigate to home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Sign In',
          style: kTextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 2.0, left: 20.0, right: 20.0, bottom: 20.0),
              child: Text(
                'Welcome to SmartH2R',
                style: kTextStyle.copyWith(color: Colors.white),
              ),
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
                      child: Image.asset('images/smart_h2r.png',
                          width: 200), // Your image goes here
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20.0),
                        SizedBox(
                          height: 60.0,
                          child: AppTextField(
                            textFieldType: TextFieldType.EMAIL,
                            controller: emailController,
                            enabled: true,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              // labelStyle: kTextStyle,
                              labelStyle: kTextStyle.copyWith(
                                  color:
                                      const Color.fromARGB(255, 238, 162, 53)),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        AppTextField(
                          textFieldType: TextFieldType.PASSWORD,
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            // labelStyle: kTextStyle,
                            labelStyle: kTextStyle.copyWith(
                                color: const Color.fromARGB(255, 238, 162, 53)),
                            hintText: 'Enter password',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                value: isChecked,
                                activeColor: kMainColor,
                                thumbColor: kGreyTextColor,
                                onChanged: (bool value) {
                                  setState(() {
                                    isChecked = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              'Save Me',
                              style: kTextStyle,
                            ),
                            const Spacer(),
                            Text(
                              'Forgot Password?',
                              style: kTextStyle,
                            ).onTap(() {
                              const ForgotPassword().launch(context);
                            }),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        ButtonGlobal(
                          buttontext: 'Sign In',
                          buttonDecoration: kButtonDecoration.copyWith(
                              color: const Color.fromARGB(255, 238, 162, 53)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              loginUser();
                            }
                          },
                        ),
                        const SizedBox(height: 20.0),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Don\'t have an account? ',
                                style: kTextStyle.copyWith(
                                  color: kGreyTextColor,
                                ),
                              ),
                              WidgetSpan(
                                child: Text(
                                  'Sign Up',
                                  style: kTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kMainColor,
                                  ),
                                ).onTap(() {
                                  const SignUp().launch(context);
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
