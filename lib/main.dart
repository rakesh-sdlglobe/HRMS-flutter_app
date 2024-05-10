import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screens/Splash Screen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 runApp(
    ChangeNotifierProvider(
      create: (_) => UserData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // Add the line below to get horizontal sliding transitions for routes.
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      title: 'Maan HRM',
      home: const SplashScreen(),
    );
  }
}

class UserData extends ChangeNotifier {
  String? token;
  String? userID;

  void setUserData(String token, String userID) {
    this.token = token;
    this.userID = userID;
    notifyListeners();
  }
}
