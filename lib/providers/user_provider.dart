import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserData extends ChangeNotifier {
  String? _token;
  String? _userID;
  String? _role;


  UserData() {
    _loadUserData();
  }

  String? get token => _token;
  String? get userID => _userID;
  String? get role => _role;


  bool get isTokenLoaded => _token != null;

  Future<void> setUserData(String token, String userID, String role) async {
    _token = token;
    _userID = userID;
    _role = role;
    notifyListeners();
    await _saveUserData();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('userID', _userID!);
    await prefs.setString('role', _role!);

  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userID = prefs.getString('userID');
    _role = prefs.getString('role');

    if (_token != null) {
      final parts = _token!.split('.');
      if (parts.length == 3) {
        final payload = json.decode(utf8.decode(base64.decode(base64.normalize(parts[1]))));
        final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
        if (expiry.isBefore(DateTime.now())) {
          // Token has expired
          _token = null;
          _userID = null;
          _role = null;
          await clearUserData();
        }
      }
    }
    notifyListeners();
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userID');
    await prefs.remove('role');
    _token = null;
    _userID = null;
    _role = null;
    notifyListeners();
  }
}
