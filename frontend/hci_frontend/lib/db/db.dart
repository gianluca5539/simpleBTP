// import hive
import 'dart:math';

import 'package:hci_frontend/db/hivemodels.dart';
import 'package:hive/hive.dart';

bool databaseInitialized = false;

void saveBTPsToDB(Map<String, Map<String, String>> btps) async {
  var box = Hive.box('btps');

  // ================== MyBTPs ==================
  await Hive.deleteBoxFromDisk('mybtps');
  await Hive.openBox('mybtps');
  var mybtpsBox = Hive.box('mybtps');
  // ================== MyBTPs ==================

  btps.forEach((key, value) {
    // ================== MyBTPs ==================
    // delete all this
    if (value['btp'] != null && value['ultimo'] != null) {
      if (Random().nextInt(10) == 0) {
        MyBTP mybtp =
            MyBTP.fromData(key, Random().nextDouble() * 100000, "01/01/2021");
        mybtpsBox.put(key, mybtp);
      }
    }
    // delete all this
    // ================== MyBTPs ==================

    BTP btp = BTP.fromData(key, value['btp']!, value['ultimo'] ?? "0",
        value['cedola'] ?? "0", value['scadenza']!);
    box.put(key, btp);
  });

  databaseInitialized = true;
}

Future<List<Map<String, dynamic>>> getHomePageMyBestBTPs() async {
  while (!databaseInitialized) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  var mybtpsBox = Hive.box('mybtps');
  var btpsBox = Hive.box('btps');

  // get all btps that have an isin in mybtps
  var mybtps = mybtpsBox.values.toList();
  var btps = btpsBox.values.toList();

  // merge the two lists by isin and retrieve only the attributes we need
  List<Map<String, dynamic>> merged = mybtps.map((mybtp) {
    var btp = btps.firstWhere((btp) => btp.isin == mybtp.isin);
    return {
      'name': btp.name,
      'value': mybtp.investment * btp.value / 100,
      'cedola': btp.cedola,
      'variation': btp.value - 100,
    };
  }).toList();

  // sort by buy price
  merged.sort((a, b) => b['variation'].compareTo(a['variation']));

  // get the first 5 elements
  List<Map<String, dynamic>> mergedList =
      merged.length > 5 ? merged.sublist(0, 5) : merged;
  return mergedList;
}

Future<List<Map<String, dynamic>>> getHomePageBestBTPs() async {
  while (!databaseInitialized) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  var box = Hive.box('btps');

  var btps = box.values.toList();
  btps.sort((a, b) => b.value.compareTo(a.value));

  List btpslist = btps.length > 5 ? btps.sublist(0, 5) : btps;

  return btpslist.map((btp) {
    return {
      'name': btp.name,
      'value': btp.value,
      'cedola': btp.cedola,
    };
  }).toList();
}