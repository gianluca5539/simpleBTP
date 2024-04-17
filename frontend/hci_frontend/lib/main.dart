import 'package:flutter/material.dart';
import 'package:hci_frontend/HomePage/homepage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hci_frontend/btp_scraper.dart';

void testBtpScraper() async {
  await fetchBtps();
  await fetchBtpPrices("IT0005217770");
}

void main() async {
  await Hive.initFlutter();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => testBtpScraper()); // Fetch data after the frame is rendered
    return const MaterialApp(
      home: HomePage(),
    );
  }
}
