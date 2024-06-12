import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrm_employee/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hrm_employee/main.dart';
import 'package:hrm_employee/Screens/Leave%20Management/edit_leave.dart';
import 'package:hrm_employee/Screens/Leave%20Management/leave_apply.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../constant.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({Key? key}) : super(key: key);

  @override
  _LeaveApplicationState createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> {
  late UserData userData;
  List<LeaveData> leaveData = [];
  late Future<void> _fetchLeaveData;

  @override
  void initState() {
    super.initState();
    userData = Provider.of<UserData>(context, listen: false);
     userData = Provider.of<UserData>(context, listen: false);
      WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (userData.isTokenLoaded) {
         fetchLeaveData();
      } else {
        userData.addListener(() {
          if (userData.isTokenLoaded) {
            setState(() {
              fetchLeaveData();
            });
          }
        });
      }
    });
  }

  Future<void> fetchLeaveData() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.7:3000/leave/get'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${userData.token}',
        },
        body: json.encode({
          'empcode': userData.userID,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> leaveRecords = jsonData['leaveRecords'];
        setState(() {
          leaveData = List<LeaveData>.from(leaveRecords.map((record) {
            print(record['leave_status']);
            String leaveType;
            if (record['leaveType'] == 1) {
              leaveType = 'Casual';
            } else if (record['leaveType'] == 3) {
              leaveType = 'plan';
            } else {
              leaveType = 'Unknown';
            }
            return LeaveData(
              leaveType: leaveType,
              // dateRange: '${record['fromdate']} to ${record['todate']}' ?? '',
              dateRange:
                  '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(record['fromdate']))} to ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(record['todate']))}' ??
                      '',
              applyDate: record['createddate'] ?? '',
              status: record['leave_status'] == 3
    ? "Rejected"
    : record['approvel_status'] == "Approved"
        ? "Approved"
        : "Pending",

            );
          }));
        });
      } else {
        throw Exception('Failed to load leave records');
      }
    } catch (error) {
      print('Error fetching leave records: $error');
      // Handle error appropriately
    }
  }

  void editLeave(BuildContext context, String leaveType, String dateRange,
      String applyDate) {
    String halfDayDateRange = ''; // Variable to store half-day date range
    String fullDayDateRange = ''; // Variable to store full-day date range

    // Logic to classify date range based on leave type
    if (leaveType == 'Casual') {
      if (dateRange.contains('(Full Day)')) {
        fullDayDateRange = dateRange;
      } else {
        halfDayDateRange = dateRange;
      }
    } else {
      fullDayDateRange = dateRange;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLeavePage(
          leaveType: leaveType,
          halfDayDateRange: halfDayDateRange,
          fullDayDateRange: fullDayDateRange,
          applyDate: applyDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _fetchLeaveData = fetchLeaveData();
              });
            },
            backgroundColor: kMainColor,
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20.0),
          FloatingActionButton(
            onPressed: () => const LeaveApply().launch(context),
            backgroundColor: kMainColor,
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: kMainColor,
      appBar: AppBar(
        backgroundColor: kMainColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Leave List',
          maxLines: 2,
          style: kTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Image(
            image: AssetImage('images/employeesearch.png'),
          ),
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
                  topRight: Radius.circular(30.0),
                ),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    for (var leave in leaveData)
                      Column(
                        children: [
                          LeaveData(
                            leaveType: leave.leaveType,
                            dateRange: leave.dateRange,
                            applyDate: leave.applyDate,
                            status: leave.status,
                            onEdit: () {
                              editLeave(
                                context,
                                leave.leaveType,
                                leave.dateRange,
                                leave.applyDate,
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10.0,
                          ), // Add space between entries
                        ],
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

class LeaveData extends StatelessWidget {
  final String leaveType;
  final String dateRange;
  final String applyDate;
  final String status;
  final Function()? onEdit;

  const LeaveData({
    Key? key,
    required this.leaveType,
    required this.dateRange,
    required this.applyDate,
    required this.status,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final casualLeaveDateFormat = DateFormat('dd, MMM yyyy HH:mm:ss');
    final casualLeaveDateFormat = DateFormat('dd, MMM yyyy');
    final planLeaveDateFormat = DateFormat('dd MMM yyyy');

    final dateRanges = dateRange.split(' to ');
    final fromDate = DateTime.parse(dateRanges[0]);
    final toDate = DateTime.parse(dateRanges[1]);

    String formattedDateRange;
    if (leaveType == 'Casual') {
      final fromDate = DateTime.parse(dateRanges[0]);
      final toDate = DateTime.parse(dateRanges[1]);

      // Check if the times are the same for both dates
      if (fromDate.hour == 0 &&
          fromDate.minute == 0 &&
          toDate.hour == 0 &&
          toDate.minute == 0) {
        formattedDateRange =
            '${casualLeaveDateFormat.format(fromDate)} (Full Day)';
      } else {
        formattedDateRange =
            '${casualLeaveDateFormat.format(fromDate)}, ${fromDate.hour}:${fromDate.minute} to ${toDate.hour}:${toDate.minute}';
      }
    } else {
      formattedDateRange =
          '${planLeaveDateFormat.format(fromDate)} to ${planLeaveDateFormat.format(toDate)}';
    }

    final applyDateFormat = DateFormat('dd, MMM yyyy');
    final formattedApplyDate =
        applyDateFormat.format(DateTime.parse(applyDate));

    Color borderColor = getStatusColor(status);
    return Material(
      elevation: 2.0,
      child: GestureDetector(
        onTap: () {
          // Handle tapping on leave entry
        },
        child: Container(
          width: context.width(),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: borderColor,
                width: 3.0,
              ),
            ),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    leaveType,
                    maxLines: 2,
                    style: kTextStyle.copyWith(
                      color: kTitleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(
                        Icons.edit,
                        size: 18.0,
                      ),
                    ),
                ],
              ),
              Text(
                formattedDateRange,
                style: kTextStyle.copyWith(
                  color: kGreyTextColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    '(Apply Date) $formattedApplyDate',
                    style: kTextStyle.copyWith(
                      color: kGreyTextColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    status,
                    style: kTextStyle.copyWith(
                      color: getStatusTextColor(status),
                    ),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  CircleAvatar(
                    radius: 10.0,
                    backgroundColor: getStatusColor(status),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return kGreenColor;
      case 'Pending':
        return kAlertColor;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getStatusTextColor(String status) {
    switch (status) {
      case 'Approved':
        return kGreenColor;
      case 'Pending':
        return kAlertColor;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
