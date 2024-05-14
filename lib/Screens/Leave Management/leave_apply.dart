import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hrm_employee/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../GlobalComponents/button_global.dart';
import '../../constant.dart';

class LeaveApply extends StatefulWidget {
  const LeaveApply({Key? key}) : super(key: key);

  @override
  _LeaveApplyState createState() => _LeaveApplyState();
}

class _LeaveApplyState extends State<LeaveApply> {
  late UserData userData;
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final oneDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final daysController =
      TextEditingController(); // New field for Number of days
  final remainingLeavesController =
      TextEditingController(text: '18'); // New field for Remaining Leaves
  List<String> numberOfInstallment = [
    'Plan Leave',
    'Casual Leave',
  ];
  String installment = 'Casual Leave';
  bool isFullDay = true;
  bool isFirstHalf = true; // New variable to track first or second half
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  @override
  void initState() {
    super.initState();
    // Add listeners to fromDateController and toDateController
    fromDateController.addListener(updateNumberOfDays);
    toDateController.addListener(updateNumberOfDays);
  }

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    oneDateController.dispose();
    daysController.dispose();
    remainingLeavesController.dispose();
    fromDateController.removeListener(updateNumberOfDays);
    toDateController.removeListener(updateNumberOfDays);
    super.dispose();
  }

  void updateNumberOfDays() {
    String fromDate = fromDateController.text;
    String toDate = toDateController.text;

    // Only update if both from date and to date are not empty
    if (fromDate.isNotEmpty && toDate.isNotEmpty) {
      // Calculate number of days between fromDate and toDate
      DateTime startDate = DateTime.parse(fromDate);
      DateTime endDate = DateTime.parse(toDate);
      int numberOfDays = endDate.difference(startDate).inDays;

      // Update the Number of days field with the calculated value
      daysController.text = numberOfDays.toString();
    }
  }

  void applyLeave() async {
  String fromdate = fromDateController.text;
  String todate = toDateController.text;
  String reason = descriptionController.text;

  // Determine the half day value based on isFullDay
  int halfDay = isFullDay ? 0 : 1;

  Map<String, dynamic> leaveValues = {
    'companyID': '10',
    'empcode': userData.userID,
    'fromdate': fromdate,
    'todate': todate,
    'reason': reason,
    'leaveid':1,
    'leavemode':1,
    'leave_adjusted':0,
    'half': halfDay // Assign halfDay value here
  };

  String jsonData = jsonEncode(leaveValues);

  String url = 'http://192.168.0.7:3000/leave/apply';

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
      print('Leave posted successfully');
    } else {
      print('Failed to post leave: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception while posting leave: $e');
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
          'Leave Apply',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 60.0,
                    child: FormField(
                      builder: (FormFieldState<dynamic> field) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Select Leave Type',
                            labelStyle: kTextStyle,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              items: numberOfInstallment.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              value: installment,
                              onChanged: (value) {
                                setState(() {
                                  installment = value!;
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  if (installment == 'Casual Leave')
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              activeColor: kMainColor,
                              value: isFullDay,
                              onChanged: (val) {
                                setState(() {
                                  isFullDay = val!;
                                });
                              },
                            ),
                            const SizedBox(width: 4.0),
                            Text('Full Day', style: kTextStyle),
                            Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              activeColor: kMainColor,
                              value: !isFullDay,
                              onChanged: (val) {
                                setState(() {
                                  isFullDay = !val!;
                                });
                              },
                            ),
                            const SizedBox(width: 4.0),
                            Text('Half Day', style: kTextStyle),
                          ],
                        ),
                        if (!isFullDay) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (picked != null &&
                                      picked != selectedStartTime) {
                                    setState(() {
                                      selectedStartTime = picked;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromARGB(
                                      255, 85, 125, 244), // Text color
                                  elevation: 4, // Shadow depth
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                  ),
                                ),
                                child: Text(selectedStartTime != null
                                    ? selectedStartTime!.format(context)
                                    : 'Select Start Time'),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  final TimeOfDay? picked =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (picked != null &&
                                      picked != selectedEndTime) {
                                    setState(() {
                                      selectedEndTime = picked;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color.fromARGB(
                                      255, 85, 125, 244), // Text color
                                  elevation: 4, // Shadow depth
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Rounded corners
                                  ),
                                ),
                                child: Text(selectedEndTime != null
                                    ? selectedEndTime!.format(context)
                                    : 'Select End Time'),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20.0),
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          onTap: () async {
                            var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            oneDateController.text =
                                date.toString().substring(0, 10);
                          },
                          controller: oneDateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: Icon(
                              Icons.date_range_rounded,
                              color: kGreyTextColor,
                            ),
                            labelText: 'One Date',
                            hintText: '11/09/2021',
                          ),
                        ),
                      ],
                    )
                  else if (installment == 'Plan Leave')
                    Column(
                      children: [
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          onTap: () async {
                            var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            fromDateController.text =
                                date.toString().substring(0, 10);
                          },
                          controller: fromDateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: Icon(
                              Icons.date_range_rounded,
                              color: kGreyTextColor,
                            ),
                            labelText: 'From Date',
                            hintText: '11/09/2021',
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          readOnly: true,
                          onTap: () async {
                            var date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            toDateController.text =
                                date.toString().substring(0, 10);
                          },
                          controller: toDateController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            suffixIcon: Icon(
                              Icons.date_range_rounded,
                              color: kGreyTextColor,
                            ),
                            labelText: 'To Date',
                            hintText: '11/09/2021',
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: daysController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Number of days',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: remainingLeavesController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Remaining Leaves',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Leave Reason',
                      hintText: 'MaanTheme',
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  ButtonGlobal(
                    buttontext: 'Apply',
                    buttonDecoration:
                        kButtonDecoration.copyWith(color: kMainColor),
                    onPressed: applyLeave,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
