import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/button_global.dart';
import '../../constant.dart';

class LeaveApply extends StatefulWidget {
  const LeaveApply({Key? key}) : super(key: key);

  @override
  _LeaveApplyState createState() => _LeaveApplyState();
}

class _LeaveApplyState extends State<LeaveApply> {
  final fromDateController = TextEditingController();
  final toDateController = TextEditingController();
  final oneDateController = TextEditingController();
  final descriptionController = TextEditingController();
  List<String> numberOfInstallment = [
    'Plan Leave',
    'Casual Leave',
  ];
  String installment = 'Casual Leave';
  bool isFullDay = true;

  @override
  void dispose() {
    fromDateController.dispose();
    toDateController.dispose();
    oneDateController.dispose();
    super.dispose();
  }

  void applyLeave() {
    if (installment == 'Casual Leave') {
      // Handle casual leave application
      String leaveCategory = installment;
      String leaveDuration =
          isFullDay != null && isFullDay! ? 'Full Day' : 'Half Day';
      String leaveDate = oneDateController.text;
      String description = descriptionController.text;
      print('Leave Category: $leaveCategory');
      print('Leave Duration: $leaveDuration');
      print('Leave Date: $leaveDate');
      print('Description: $description');
    } else if (installment == 'Plan Leave') {
      // Handle planned leave application
      String leaveCategory = installment;
      String fromDate = fromDateController.text;
      String toDate = toDateController.text;
      String description = descriptionController.text;
      print('Leave Category: $leaveCategory');
      print('From Date: $fromDate');
      print('To Date: $toDate');
      print('Description: $description');
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
                      Row(
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
                              }),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            'Full Day',
                            style: kTextStyle,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              activeColor: kMainColor,
                              value: !isFullDay,
                              onChanged: (val) {
                                setState(() {
                                  isFullDay = !isFullDay;
                                });
                              }),
                          const SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            'Half Day',
                            style: kTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
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
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: kInputDecoration.copyWith(
                      labelText: 'Description',
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
