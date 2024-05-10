import 'package:flutter/material.dart';
import 'package:hrm_employee/constant.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:nb_utils/nb_utils.dart';

class AttendanceStorage extends StatefulWidget {
  const AttendanceStorage({Key? key}) : super(key: key);

  @override
  State<AttendanceStorage> createState() => _AttendanceStorageState();
}

class _AttendanceStorageState extends State<AttendanceStorage> {
  late Future<List<Map<String, dynamic>>> _attendanceData;
  DateTime selectedDate = DateTime.now();
  int presentDays = 0;
  int absentDays = 0;

  @override
  void initState() {
    super.initState();
    _attendanceData = _fetchAttendanceData();
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceData() async {
    Database database = await _openDatabase();
    return await database.query('attendance');
  }

  Future<Database> _openDatabase() async {
    String path = join(await getDatabasesPath(), 'attendance.db');
    return await openDatabase(path);
  }

  Future<void> _deleteAllData() async {
    Database database = await _openDatabase();
    await database.delete('attendance');
    setState(() {
      _attendanceData = _fetchAttendanceData();
    });
  }

  String getStatus(bool isCheckedIn, bool isCheckedOut) {
    if (isCheckedIn && isCheckedOut) {
      return 'Present';
    } else {
      return 'Absent';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ignore: unused_element
  void _showPresentAbsentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Present and Absent Days'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Present Days: $presentDays'),
              Text('Absent Days: $absentDays'),
            ],
          ),
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
  Widget build(BuildContext context) {
    presentDays = 0; // Reset presentDays
    absentDays = 0; // Reset absentDays

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Attendance Storage',
          style: kTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: kTextStyle.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 4.0),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                  ),
                ],
              ),
            ).onTap(() => _selectDate(context)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _deleteAllData,
        // onPressed: () => _showPresentAbsentDialog(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.delete_forever, color: Colors.white),
        // child: const Icon(Icons.info, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: kMainColor,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
              color: Colors.white,
            ),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _attendanceData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<Map<String, dynamic>> attendanceList = snapshot.data!;
                  Map<String, List<Map<String, dynamic>>> groupedAttendance =
                      {};
                  // Grouping attendance by date
                  attendanceList.forEach((attendance) {
                    String date = attendance['date'];
                    if (!groupedAttendance.containsKey(date)) {
                      groupedAttendance[date] = [];
                    }
                    groupedAttendance[date]!.add(attendance);
                  });
                  groupedAttendance.forEach((date, attendances) {
                    bool hasCheckedIn = false;
                    bool hasCheckedOut = false;
                    attendances.forEach((attendance) {
                      if (attendance['isCheckIn'] == 1) {
                        hasCheckedIn = true;
                      } else {
                        hasCheckedOut = true;
                      }
                    });
                    if (hasCheckedIn && hasCheckedOut) {
                      presentDays++;
                    } else {
                      absentDays++;
                    }
                  });
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20.0),
                      Material(
                        elevation: 2.0,
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'Date',
                                        style: kTextStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'In Time',
                                        style: kTextStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'Out Time',
                                        style: kTextStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        'Status',
                                        style: kTextStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Divider(
                                  color: kBorderColorTextField,
                                  thickness: 1.0,
                                ),
                              ),
                              ...groupedAttendance.entries.map((entry) {
                                String date = entry.key;
                                List<Map<String, dynamic>> attendances =
                                    entry.value;
                                // Assuming there's only one check-in and one check-out entry per date
                                Map<String, dynamic> checkIn =
                                    attendances.firstWhere(
                                  (attendance) => attendance['isCheckIn'] == 1,
                                  orElse: () =>
                                      {}, // Replace null with an empty Map
                                );
                                Map<String, dynamic> checkOut =
                                    attendances.firstWhere(
                                  (attendance) => attendance['isCheckIn'] == 0,
                                  orElse: () =>
                                      {}, // Replace null with an empty Map
                                );
                                String inTime =
                                    checkIn.isNotEmpty ? checkIn['time'] : '-';
                                String outTime = checkOut.isNotEmpty
                                    ? checkOut['time']
                                    : '-';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            date,
                                            style: kTextStyle.copyWith(
                                              color: kGreyTextColor,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            inTime,
                                            style: kTextStyle.copyWith(
                                              color: kGreyTextColor,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            outTime,
                                            style: kTextStyle.copyWith(
                                              color: kGreyTextColor,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            getStatus(
                                              checkIn.isNotEmpty,
                                              checkOut.isNotEmpty,
                                            ),
                                            style: kTextStyle.copyWith(
                                              color: checkIn.isNotEmpty ||
                                                      checkOut.isNotEmpty
                                                  ? Colors.green
                                                  : Colors.redAccent,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              // ignore: unnecessary_to_list_in_spreads
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
