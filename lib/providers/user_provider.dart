import 'package:flutter/material.dart';

class UserData extends ChangeNotifier {
  String? token;
  String? userID;

  void setUserData(String token, String userID) {
    this.token = token;
    this.userID = userID;
    notifyListeners();
  }
}