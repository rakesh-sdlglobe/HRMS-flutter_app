import 'package:flutter/material.dart';
import 'package:hrm_employee/providers/attendance_provider.dart';
import 'package:hrm_employee/providers/attendance_storage_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/Home/home_screen.dart';
import 'Screens/Splash Screen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AttendanceProvider()),
          ChangeNotifierProvider(
              create: (context) =>
                  AttendanceStorageProvider()), // Fix provided here
        ],
        child: MaterialApp(
            theme: ThemeData(
              // Add the line below to get horizontal sliding transitions for routes.
              pageTransitionsTheme: const PageTransitionsTheme(builders: {
                TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              }),
            ),
            title: 'SmartH2R HRMS',
            home: const SplashScreen(),
            routes: <String, WidgetBuilder>{
              '/homescreen': (BuildContext context) => const HomeScreen(),
            }));
  }
}
