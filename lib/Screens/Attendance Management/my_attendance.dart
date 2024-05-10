import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hrm_employee/constant.dart';
import 'package:hrm_employee/services/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';

class MyAttendance extends StatefulWidget {
  const MyAttendance({
    Key? key,
  }) : super(key: key);

  @override
  _MyAttendanceState createState() => _MyAttendanceState();
}

class _MyAttendanceState extends State<MyAttendance> {
  bool isOffice = true;
  late Timer _timer;
  late DateTime _currentTime;
  late String formattedDate;
  late String intime;
  late String dayOfWeek;
  bool isCheckedIn = false;
  late UserData userData;
  List<Map<String, String>> attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
      formattedDate = DateFormat('dd-MMM-yyyy').format(_currentTime);
      dayOfWeek = DateFormat('EEEE').format(_currentTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  DatabaseHelper _databaseHelper = DatabaseHelper();
  void checkIn() async {
    // Check if the user has already checked in for today
    intime =
        '${_currentTime.year}-${_currentTime.month}-${_currentTime.day} ${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}';

    List<Map<String, dynamic>> todayAttendance =
        await _databaseHelper.getAttendanceByDate(formattedDate);

    // If the user has already checked in, show a message and return
    if (todayAttendance.isNotEmpty && todayAttendance.first['isCheckIn'] == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already checked in for today.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // If the user hasn't checked in yet, record the check-in time
    Map<String, dynamic> attendanceData = {
      'date': formattedDate,
      'time':
          '${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}',
      'isCheckIn': 1,
    };

    await _databaseHelper.insertAttendance(attendanceData);

    setState(() {
      isCheckedIn = true;
    });
  }

  void checkOut() async {
    // Record the current time as the check-out time
    String outime =
        '${_currentTime.year}-${_currentTime.month}-${_currentTime.day} ${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}';

    // Check if the user has already checked out for today
    List<Map<String, dynamic>> todayAttendance =
        await _databaseHelper.getAttendanceByDate(formattedDate);

    // If the user has already checked out, show a message and return
    if (todayAttendance.isNotEmpty && todayAttendance.first['isCheckIn'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already checked out for today.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Record the check-out time locally
    Map<String, dynamic> attendanceData = {
      'date': formattedDate,
      'time': outime,
      'isCheckIn': 0,
    };

    await _databaseHelper.insertAttendance(attendanceData);

    setState(() {
      isCheckedIn = false;
    });

    // Call attendanceValues with outime
    attendanceValues( outime: outime);
  }

  void attendanceValues(
      {required String outime}) async {

    Map<String, dynamic> attendanceValues = {
      'companyID': '10',
      'empcode': userData.userID,
      'exactdate': formattedDate,
      'intime': intime,
      'outtime': outime,
    };

    String jsonData = jsonEncode(attendanceValues);

    String url = 'http://192.168.0.7:3000/attendance/time';
    // String? authToken = userData.token;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
        print('Out time posted successfully');
      } else {
        print('Failed to post out time: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while posting out time: $e');
    }
  }

  void showCheckInSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please check in first.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void viewAttendance() async {
    // Fetch today's attendance records from the database
    List<Map<String, dynamic>> todayAttendance =
        await _databaseHelper.getAttendanceByDate(formattedDate);

    // Create a dialog box to display today's attendance
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Today\'s Attendance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date: $formattedDate',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (todayAttendance.isEmpty)
                const Text('No attendance recorded for today.')
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: todayAttendance.map((record) {
                    String time = record['time'];
                    bool isCheckIn = record['isCheckIn'] == 1;

                    return Text(
                      '$time - ${isCheckIn ? 'Checked In' : 'Checked Out'}',
                    );
                  }).toList(),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<UserData>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        title: Text(
          'Employee Directory',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.history,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20.0),
          Expanded(
            child: Container(
              width: context.width(),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                color: kBgColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: context.width(),
                    padding: const EdgeInsets.all(14.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Your Location:',
                          style:
                              kTextStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Location Not Found',
                          style: kTextStyle.copyWith(color: kGreyTextColor),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: kMainColor.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.rotate_right,
                            color: kMainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: context.width(),
                      padding: const EdgeInsets.all(30.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Choose your Attendance mode',
                            style: kTextStyle.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10.0),
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: kMainColor,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: isOffice ? Colors.white : kMainColor,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: kMainColor,
                                        child: Icon(
                                          Icons.check,
                                          color: isOffice
                                              ? Colors.white
                                              : kMainColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        'Office',
                                        style: kTextStyle.copyWith(
                                          color: isOffice
                                              ? kTitleColor
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                    ],
                                  ),
                                ).onTap(() {
                                  setState(() {
                                    isOffice = true;
                                  });
                                }),
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color:
                                        !isOffice ? Colors.white : kMainColor,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: kMainColor,
                                        child: Icon(
                                          Icons.check,
                                          color: !isOffice
                                              ? Colors.white
                                              : kMainColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        'Outside',
                                        style: kTextStyle.copyWith(
                                          color: !isOffice
                                              ? kTitleColor
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12.0),
                                    ],
                                  ),
                                ).onTap(() {
                                  setState(() {
                                    isOffice = false;
                                  });
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Text(
                            _currentTime.hour < 12
                                ? "Good Morning"
                                : _currentTime.hour < 16
                                    ? "Good Afternoon"
                                    : "Good Evening",
                            style: kTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '$dayOfWeek, $formattedDate',
                            style: kTextStyle.copyWith(color: kGreyTextColor),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            _currentTime != null
                                ? '${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}'
                                : 'Loading...',
                            style: kTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 25.0,
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100.0),
                              color: isOffice
                                  ? kGreenColor.withOpacity(0.1)
                                  : kAlertColor.withOpacity(0.1),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                if (isOffice) {
                                  isCheckedIn ? checkOut() : checkIn();
                                } else {
                                  isCheckedIn
                                      ? checkOut()
                                      : showCheckInSnackBar();
                                }
                              },
                              child: CircleAvatar(
                                radius: 80.0,
                                backgroundColor:
                                    isOffice ? kGreenColor : kAlertColor,
                                child: Text(
                                  isOffice ? 'Check In' : 'Check Out',
                                  style: kTextStyle.copyWith(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewAttendance,
        backgroundColor: const Color.fromARGB(255, 86, 125, 244),
        child: const Icon(Icons.remove_red_eye, color: Colors.white),
      ),
    );
  }
}
