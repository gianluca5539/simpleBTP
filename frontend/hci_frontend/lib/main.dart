import 'package:flutter/material.dart';
import 'package:hci_frontend/HomePage/homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // use DIN Alternate as the default font
      theme: ThemeData(fontFamily: 'DIN Alternate'),
      home: const HomePage(),
    );
  }
}
