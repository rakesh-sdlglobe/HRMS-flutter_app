import 'package:flutter/material.dart';
import 'package:hrm_employee/constant.dart';
import 'package:hrm_employee/providers/attendance_provider.dart';
import 'package:hrm_employee/services/location_util.dart';
// ignore: depend_on_referenced_packages
import 'package:nb_utils/nb_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

class MyAttendance extends StatelessWidget {
  const MyAttendance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        body: Consumer<AttendanceProvider>(
          builder: (context, provider, _) {
            return Column(
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
                                style: kTextStyle.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                'Location Not Found',
                                style:
                                    kTextStyle.copyWith(color: kGreyTextColor),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: kMainColor.withOpacity(0.1),
                                ),
                                child: GestureDetector(
                                  onTap: (() => _getLocation(context)),
                                  child: const Icon(
                                    Icons.rotate_right,
                                    color: kMainColor,
                                  ),
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
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          color: provider.isOffice
                                              ? Colors.white
                                              : kMainColor,
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: kMainColor,
                                              child: Icon(
                                                Icons.check,
                                                color: provider.isOffice
                                                    ? Colors.white
                                                    : kMainColor,
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              'Office',
                                              style: kTextStyle.copyWith(
                                                color: provider.isOffice
                                                    ? kTitleColor
                                                    : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 12.0),
                                          ],
                                        ),
                                      ).onTap(() {
                                        provider.setAttendanceMode(true);
                                      }),
                                      Container(
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          color: !provider.isOffice
                                              ? Colors.white
                                              : kMainColor,
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: kMainColor,
                                              child: Icon(
                                                Icons.check,
                                                color: !provider.isOffice
                                                    ? Colors.white
                                                    : kMainColor,
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              'Outside',
                                              style: kTextStyle.copyWith(
                                                color: !provider.isOffice
                                                    ? kTitleColor
                                                    : Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 12.0),
                                          ],
                                        ),
                                      ).onTap(() {
                                        provider.setAttendanceMode(false);
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30.0),
                                Text(
                                  provider.greetingMessage,
                                  style: kTextStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  '${provider.dayOfWeek}, ${provider.formattedDate}',
                                  style: kTextStyle.copyWith(
                                      color: kGreyTextColor),
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                  // ignore: unnecessary_null_comparison
                                  provider.currentTime != null
                                      ? '${provider.currentTime.hour}:${provider.currentTime.minute}:${provider.currentTime.second}'
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
                                    color: provider.isOffice
                                        ? kGreenColor.withOpacity(0.1)
                                        : kAlertColor.withOpacity(0.1),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (provider.isOffice) {
                                        provider.isCheckedIn
                                            ? provider.checkOut(context)
                                            : provider.checkIn(context);
                                      } else {
                                        provider.isCheckedIn
                                            ? provider.checkOut(context)
                                            : provider
                                                .showCheckInSnackBar(context);
                                      }
                                    },
                                    child: CircleAvatar(
                                      radius: 80.0,
                                      backgroundColor: provider.isOffice
                                          ? kGreenColor
                                          : kAlertColor,
                                      child: Text(
                                        provider.isOffice
                                            ? 'Check In'
                                            : 'Check Out',
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
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                Provider.of<AttendanceProvider>(context, listen: false)
                    .viewAttendance(context);
              },
              backgroundColor: const Color.fromARGB(255, 86, 125, 244),
              child: const Icon(Icons.remove_red_eye, color: Colors.white),
            ),
            const SizedBox(height: 10.0),
            FloatingActionButton(
              onPressed: () {
                Provider.of<AttendanceProvider>(context, listen: false)
                    .viewLocation(context);
              },
              backgroundColor: const Color.fromARGB(255, 86, 125, 244),
              child:
                  const Icon(Icons.location_city_outlined, color: Colors.white),
            ),
          ],
        ));
  }

  void _getLocation(BuildContext context) async {
    await LocationUtil.getLocation(
        context); // Call _getLocation from LocationUtil
  }
}
