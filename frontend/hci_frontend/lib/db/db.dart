// import hive
import 'package:hci_frontend/db/hivemodels.dart';
import 'package:hive/hive.dart';

// create object MyBTP with attributes buy date, buy price
// class MyBTP {
//   late DateTime buyDate;
//   late double buyPrice;
//   late String isin;

//   MyBTP({required this.buyDate, required this.buyPrice, required this.isin});
// }

void saveBTPsToDB(Map<String, Map<String, String>> btps) {
  var box = Hive.box('btps');
  box.clear();
  btps.forEach((key, value) {
    BTP btp = BTP(key, value['btp']!, value['ultimo']!, value['cedola']!,
        value['scadenza']!);
    box.put(key, btp);
  });
}

Future<List<Map<String, dynamic>>> getHomePageBestBTPs() async {
  // while loop that waits for box to be non empty
  while (Hive.box('btps').isEmpty) {
    await Future.delayed(const Duration(seconds: 1));
  }
  var box = Hive.box('btps');
  var btps = box.values.toList();
  btps.sort((a, b) => b.value.compareTo(a.value));
  return btps.sublist(0, 5).map((btp) {
    double variation = btp.value - 100;
    return {
      'name': btp.name,
      'value': btp.value,
      'cedola': btp.cedola,
      'variation': double.parse(variation.toStringAsFixed(3)),
    };
  }).toList();
}
