// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:simpleBTP/HomePage/homepage.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/db/db.dart';
import 'package:simpleBTP/db/hivemodels.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BTPAdapter());
  Hive.registerAdapter(MyBTPAdapter());

  // load settings
  await Hive.openBox('settings');
  // set the default language to italian
  selectedLang = Hive.box('settings').get('language');
  if (selectedLang == null) {
    Hive.box('settings').put('language', 'en');
    selectedLang = 'en';
  }

  loadData();
  runApp(const MainApp());
}

Future<void> loadData() async {
  await Hive.openBox('utils');

  var utilsBox = Hive.box('utils');
  var lastFetch = utilsBox.get('lastFetch');

  if (lastFetch == null) {
    lastFetch = DateTime.now().subtract(const Duration(hours: 3));
    utilsBox.put('lastFetch', lastFetch);
  }

  await Hive.openBox('mybtps');

  if (DateTime.now().difference(lastFetch) > const Duration(hours: 3) || true) {
    utilsBox.put('lastFetch', DateTime.now());
    await Hive.deleteBoxFromDisk('btps');
    await Hive.openBox('btps');
    fetchBtps().then((value) => saveBTPsToDB(value));
  } else {
    // for debugging purposes caching is disabled
    await Hive.openBox('btps');
    databaseInitialized = true;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'DIN Alternate'),
      home: const HomePage(),
    );
  }
}
