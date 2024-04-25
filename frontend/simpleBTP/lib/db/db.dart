// import hive
import 'dart:async';
import 'dart:math';

import 'package:simpleBTP/db/hivemodels.dart';
import 'package:hive/hive.dart';

bool databaseInitialized = false;

double minBTPVal = 999999;
double maxBTPVal = 0;
double minBTPCedola = 999999;
double maxBTPCedola = 0;

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
            MyBTP.fromData(key, Random().nextDouble() * 100000, "01/01/2024");
        mybtpsBox.put(key, mybtp);
      }
    }
    // delete all this
    // ================== MyBTPs ==================

    BTP btp = BTP.fromData(key, value['btp']!, value['ultimo'] ?? "0",
        value['cedola'] ?? "0", value['scadenza']!);

    if (btp.value != 0) {
      // update min and max values
      if (btp.value < minBTPVal) {
        minBTPVal = btp.value;
      }
      if (btp.value > maxBTPVal) {
        maxBTPVal = btp.value;
      }
      if (btp.cedola < minBTPCedola) {
        minBTPCedola = btp.cedola;
      }
      if (btp.cedola > maxBTPCedola) {
        maxBTPCedola = btp.cedola;
      }
      
      box.put(key, btp);
    }
  });

  databaseInitialized = true;
}

Future<Map<String, double>> getWalletStats() async {
  while (!databaseInitialized) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  var mybtpsBox = Hive.box('mybtps');
  var btpsBox = Hive.box('btps');

  var mybtps = mybtpsBox.values.toList();
  var btps = btpsBox.values.toList();

  double balance = 0.0;
  double initialBalance = 0.0;

  for (var mybtp in mybtps) {
    var btp = btps.firstWhere((btp) => btp.isin == mybtp.isin);
    balance += mybtp.investment * btp.value / 100;
    initialBalance += mybtp.investment;
  }

  return {
    "balance": balance,
    "variation": (balance - initialBalance) / initialBalance * 100,
  };
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
      'isin': btp.isin,
      'variation': btp.value - 100,
    };
  }).toList();

  // sort by buy price
  merged.sort((a, b) => b['variation'].compareTo(a['variation']));

  // get the first 5 elements
  List<Map<String, dynamic>> mergedList =
      merged.length > 3 ? merged.sublist(0, 3) : merged;
  return mergedList;
}

Future<List<Map<String, dynamic>>> getWalletPageMyBTPs() async {
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
      'isin': btp.isin,
      'variation': btp.value - 100,
      'buyDate': mybtp.buyDate,
    };
  }).toList();

  // sort by buy price
  merged.sort((a, b) => b['variation'].compareTo(a['variation']));

  // get the first 5 elements
  List<Map<String, dynamic>> mergedList =
      merged.length > 3 ? merged.sublist(0, 3) : merged;
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
      'isin': btp.isin,
      'cedola': btp.cedola,
    };
  }).toList();
}

Future<List<Map<String, dynamic>>> getMyBTPs() async {
  while (!databaseInitialized) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  var mybtpsBox = Hive.box('mybtps');
  var btpsBox = Hive.box('btps');

  var mybtps = mybtpsBox.values.toList();
  var btps = btpsBox.values.toList();

  List<Map<String, dynamic>> merged = mybtps.map((mybtp) {
    var btp = btps.firstWhere((btp) => btp.isin == mybtp.isin);
    return {
      'name': btp.name,
      'value': btp.value,
      'cedola': btp.cedola,
      'isin': mybtp.isin,
      'investment': mybtp.investment,
      'buyDate': mybtp.buyDate,
    };
  }).toList();

  return merged;
}

Future<List<Map<String, dynamic>>> getExplorePageBTPs(
    search, filters, ordering) async {
  while (!databaseInitialized) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  var box = Hive.box('btps');

  var btps = box.values.toList();

  // apply search
  if (search != null && search != "") {
    btps = btps
        .where((btp) => btp.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  // apply filters
  List<BTP> btpsFiltered = [];
  for (var btp in btps) {
    if (filters['minValue'] != null && btp.value < filters['minValue']) {
      continue;
    }
    if (filters['maxValue'] != null && btp.value > filters['maxValue']) {
      continue;
    }
    if (filters['minCedola'] != null && btp.cedola * 2 < filters['minCedola']) {
      continue;
    }
    if (filters['maxCedola'] != null && btp.cedola * 2 > filters['maxCedola']) {
      continue;
    }
    if (filters['minExpiration'] != null &&
        btp.expirationDate.isBefore(filters['minExpiration'])) {
      continue;
    }
    if (filters['maxExpiration'] != null &&
        btp.expirationDate.isAfter(filters['maxExpiration'])) {
      continue;
    }
    btpsFiltered.add(btp);
  }

  // sort
  if (ordering['orderBy'] == 'value') {
    if (ordering['order'] == 'desc') {
      btpsFiltered.sort((a, b) => b.value.compareTo(a.value));
    } else {
      btpsFiltered.sort((a, b) => a.value.compareTo(b.value));
    }
  } else if (ordering['orderBy'] == 'cedola') {
    if (ordering['order'] == 'desc') {
      btpsFiltered.sort((a, b) => b.cedola.compareTo(a.cedola));
    } else {
      btpsFiltered.sort((a, b) => a.cedola.compareTo(b.cedola));
    }
  } else if (ordering['orderBy'] == 'expirationDate') {
    if (ordering['order'] == 'desc') {
      btpsFiltered.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    } else {
      btpsFiltered.sort((a, b) => b.expirationDate.compareTo(a.expirationDate));
    }
  }

  return btpsFiltered.map((btp) {
    return {
      'name': btp.name,
      'value': btp.value,
      'isin': btp.isin,
      'cedola': btp.cedola,
    };
  }).toList();
}
