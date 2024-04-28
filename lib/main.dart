import 'package:flutter/material.dart';
import 'package:indoor_explorer_client/screens/calibrate.dart';
import 'package:indoor_explorer_client/screens/navigate.dart';
import 'screens/find_my_location.dart';
import 'screens/get_started_screen.dart';
import 'screens/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Get Started Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GetStartedScreen(),
      routes: <String, WidgetBuilder>{
        '/get_started_screen': (context) => const GetStartedScreen(),
        '/home': (context) => const Home(),
        '/find_my_location': (context) => MyLocation(),
        '/navigate': (context) => Navigation(),
        '/calibrate': (context) => Calibration(),
      },
    );
  }
}
