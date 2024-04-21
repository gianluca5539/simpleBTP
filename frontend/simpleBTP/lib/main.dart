import 'package:flutter/material.dart';
import 'package:simpleBTP/HomePage/homepage.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/db/db.dart';
import 'package:simpleBTP/db/hivemodels.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BTPAdapter());
  Hive.registerAdapter(MyBTPAdapter());
  loadData();
  runApp(const MainApp());
}

Future<void> loadData() async {
  await Hive.deleteBoxFromDisk('btps');
  await Hive.openBox('btps');
  await Hive.openBox('mybtps');
  fetchBtps().then((value) => saveBTPsToDB(value));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'DIN Alternate'),
      home: const HomePage(),
    );
  }
}
