// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';
import 'edit_profile.dart';
import 'package:hrm_employee/providers/user_provider.dart';

import 'package:provider/provider.dart';
import '../../GlobalComponents/button_global.dart';
import '../Attendance Management/management_screen.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserData userData;
   String? userName;
 String? email;
 String? mobile;
 String? gender;
  
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (userData.isTokenLoaded) {
        fetchUserName();
      } else {
        userData.addListener(() {
          if (userData.isTokenLoaded) {
            setState(() {
              fetchUserName();
            });
          }
        });
      }
    });
  }
   Future<void> fetchUserName() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.7:3000/auth/getUser'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'empcode': userData.userID,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          userName = json.decode(response.body)['empName'];
          email = json.decode(response.body)['email'];
          mobile = json.decode(response.body)['mobile'];
          gender = json.decode(response.body)['gender'];
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      // Handle error here, e.g., show a message to the user
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Profile',
          maxLines: 2,
          style: kTextStyle.copyWith(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
  const Image(
    image: AssetImage('images/editprofile.png'),
  ).onTap(() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(
          userName: userName ?? 'Loading..',
          email: email ?? 'Loading..',
          mobile: mobile ?? 'Loading..',
          gender: gender ?? 'Loading..', companyName: 'Sdlglobe Technologies Pvt Ltd',
           companyAddress: 'Geleyara Balaga Layout, Jalahalli West, Bengaluru, Myadarahalli, Karnataka 560090',
        ),
      ),
    );
  }),
],

      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: Container(
              width: context.width(),
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    const CircleAvatar(
                      radius: 60.0,
                      backgroundColor: kMainColor,
                      backgroundImage: AssetImage(
                        'images/emp1.png',
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    AppTextField(
                      readOnly: true,
                      textFieldType: TextFieldType.NAME,
                      decoration:  InputDecoration(
                        labelText: 'Company Name',
                        hintText: 'Sdlglobe Technologies Pvt Ltd',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    AppTextField(
                      readOnly: true,
                      textFieldType: TextFieldType.NAME,
                      decoration:  InputDecoration(
                        labelText: 'Owner/Admin name',
                        hintText: userName ?? 'Loading..',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    AppTextField(
                      readOnly: true,
                      textFieldType: TextFieldType.EMAIL,
                      decoration:  InputDecoration(
                        labelText: 'Email Address',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: email ?? 'Loading..',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    AppTextField(
                      textFieldType: TextFieldType.PHONE,
                      controller: TextEditingController(),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: mobile ?? 'Loading..',
                        labelStyle: kTextStyle,
                        border: const OutlineInputBorder(),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    AppTextField(
                      readOnly: true,
                      textFieldType: TextFieldType.NAME,
                      decoration: const InputDecoration(
                        labelText: 'Company Address',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'Geleyara Balaga Layout, Jalahalli West, Bengaluru, Myadarahalli, Karnataka 560090',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      readOnly: true,
                      decoration:  InputDecoration(
                        labelText: 'Gender',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: gender ?? 'Loading..',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
