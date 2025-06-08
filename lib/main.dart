import 'package:crms2/screens/Auth/login.dart';
import 'package:crms2/screens/Auth/register.dart';
import 'package:crms2/screens/homescreen.dart';
import 'package:crms2/screens/main_screen.dart';
import 'package:crms2/screens/profile.dart';
import 'package:crms2/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
      routes: {
        "/mainscreen": (context) => const MainScreen(),
        "/registerscreen": (context) => const PoliceStationRegistrationPage(),
        "/loginscreen": (context) => const PoliceStationLoginPage(),
        "/homescreen": (context) => const HomeScreen(),
        "/profile": (context) => const ProfilePage(),
      },
    );
  }
}
