// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class AttendanceStorageProvider extends ChangeNotifier {
//   late Future<List<Map<String, dynamic>>> attendanceData =
//       _fetchAttendanceData();
//   DateTime selectedDate = DateTime.now();
//   int presentDays = 0;
//   int absentDays = 0;

//   AttendanceStorageProvider();

//   Future<List<Map<String, dynamic>>> _fetchAttendanceData() async {
//     Database database = await _openDatabase();
//     return _getAttendanceData(database);
//   }

//   Future<Database> _openDatabase() async {
//     String path = join(await getDatabasesPath(), 'attendance.db');
//     return openDatabase(path);
//   }

//   Future<List<Map<String, dynamic>>> _getAttendanceData(
//       Database database) async {
//     return database.query('attendance');
//   }

//   Future<void> deleteAllData() async {
//     Database database = await _openDatabase();
//     await database.delete('attendance');
//     _fetchAttendanceData();
//   }

//   String getStatus(bool isCheckedIn, bool isCheckedOut) {
//     return isCheckedIn && isCheckedOut ? 'Present' : 'Absent';
//   }

//   Future<void> selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2015, 8),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != selectedDate) {
//       selectedDate = picked;
//       notifyListeners();
//     }
//   }

//   void showPresentAbsentDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Present and Absent Days'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Present Days: $presentDays'),
//               Text('Absent Days: $absentDays'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
