import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hrm_employee/Screens/Leave%20Management/edit_leave.dart';
import 'package:hrm_employee/Screens/Leave%20Management/leave_apply.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:intl/intl.dart';
import '../../constant.dart';

class LeaveApplication extends StatefulWidget {
  const LeaveApplication({Key? key}) : super(key: key);

  @override
  _LeaveApplicationState createState() => _LeaveApplicationState();
}

class _LeaveApplicationState extends State<LeaveApplication> {
  List<LeaveEntryData> leaveData = [
    const LeaveEntryData(
      leaveType: 'Plan Leave',
      dateRange: '2021-05-16 to 2021-05-20',
      applyDate: '2021-05-15',
      status: 'Pending',
    ),
    const LeaveEntryData(
      leaveType: 'Casual Leave',
      dateRange: '2021-05-16 to 2021-05-16',
      applyDate: '2021-05-15',
      status: 'Approved',
    ),
    const LeaveEntryData(
      leaveType: 'Casual Leave',
      dateRange: '2021-05-16 to 2021-05-16',
      applyDate: '2021-05-15',
      status: 'Approved',
    ),
    const LeaveEntryData(
      leaveType: 'Plan Leave',
      dateRange: '2021-05-16 to 2021-05-20',
      applyDate: '2021-05-15',
      status: 'Pending',
    ),
    const LeaveEntryData(
      leaveType: 'Casual Leave',
      dateRange: '2021-05-16 to 2021-05-16',
      applyDate: '2021-05-15',
      status: 'Rejected',
    ),
    const LeaveEntryData(
      leaveType: 'Plan Leave',
      dateRange: '2021-05-16 to 2021-05-20',
      applyDate: '2021-05-15',
      status: 'Pending',
    ),
    const LeaveEntryData(
      leaveType: 'Plan Leave',
      dateRange: '2021-05-16 to 2021-05-20',
      applyDate: '2021-05-15',
      status: 'Approved',
    ),
  ];

  void editLeave(BuildContext context, String leaveType, String dateRange,
      String applyDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditLeave(
                leaveType: leaveType,
                dateRange: dateRange,
                applyDate: applyDate,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => const LeaveApply().launch(context),
        backgroundColor: kMainColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
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
              color: Colors.white, fontWeight: FontWeight.bold),
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
                    topRight: Radius.circular(30.0)),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    for (var i = 0; i < leaveData.length; i++)
                      Column(
                        children: [
                          LeaveEntryData(
                            leaveType: leaveData[i].leaveType,
                            dateRange: leaveData[i].dateRange,
                            applyDate: leaveData[i].applyDate,
                            status: leaveData[i].status,
                            onEdit: () {
                              editLeave(
                                context,
                                leaveData[i].leaveType,
                                leaveData[i].dateRange,
                                leaveData[i].applyDate,
                              );
                            },
                          ),
                          const SizedBox(
                              height: 10.0), // Add space between entries
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

class LeaveEntryData extends StatelessWidget {
  final String leaveType;
  final String dateRange;
  final String applyDate;
  final String status;
  final Function()? onEdit;

  const LeaveEntryData({
    Key? key,
    required this.leaveType,
    required this.dateRange,
    required this.applyDate,
    required this.status,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final casualLeaveDateFormat = DateFormat('dd, MMM yyyy');
    final plannedLeaveDateFormat = DateFormat('dd MMM yyyy');

    final dateRanges = dateRange.split(' to ');
    final fromDate = DateTime.parse(dateRanges[0]);
    final toDate = DateTime.parse(dateRanges[1]);

    final formattedDateRange = leaveType == 'Casual Leave'
        ? '${casualLeaveDateFormat.format(fromDate)}'
        : '${plannedLeaveDateFormat.format(fromDate)} to ${plannedLeaveDateFormat.format(toDate)}';
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
                // color: Color(0xFF7D6AEF),
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
                        color: kTitleColor, fontWeight: FontWeight.bold),
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
                    '(Apply Date) $applyDate',
                    style: kTextStyle.copyWith(
                      color: kGreyTextColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    status,
                    style: kTextStyle.copyWith(
                      color: getStatusColor(status),
                    ),
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  CircleAvatar(
                    radius: 10.0,
                    backgroundColor: getStatusColor(status),
                    child: Icon(
                      getIconForStatus(status),
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
        return kGreyTextColor;
    }
  }

  IconData getIconForStatus(String status) {
    switch (status) {
      case 'Approved':
        return Icons.check;
      case 'Pending':
        return Icons.pending;
      case 'Rejected':
        return Icons.close;
      default:
        return Icons.info;
    }
  }
}
