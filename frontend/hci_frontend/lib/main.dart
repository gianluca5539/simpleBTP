import 'package:flutter/material.dart';
import 'package:hci_frontend/HomePage/homepage.dart';
import 'package:hci_frontend/btp_scraper.dart';
import 'package:hci_frontend/db/db.dart';
import 'package:hci_frontend/db/hivemodels.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BTPAdapter());
  loadData();
  runApp(const MainApp());
}

void loadData() async {
  await Hive.openBox('btps');
  fetchBtps().then((value) => saveBTPsToDB(value));
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
