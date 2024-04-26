import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpinvestmentcomponent.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpsearch.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/db/db.dart';

class AddBTPFirstPage extends StatefulWidget {
  AddBTPFirstPage({Key? key}) : super(key: key);

  @override
  State<AddBTPFirstPage> createState() => _AddBTPFirstPageState();
}

class _AddBTPFirstPageState extends State<AddBTPFirstPage> {
  String search = '';

  Map<String, dynamic> filters = defaultAddBTPFilters;

  Map<String, dynamic> ordering = defaultAddBTPOrdering;

  void searchWithFilters(String search, Map<String, dynamic> filters,
      Map<String, dynamic> ordering) {
    // update the state with the new search and filters
    setState(() {
      this.search = search;
      this.filters = filters;
      this.ordering = ordering;
    });
  }

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : Colors.white,
      appBar: AppTopBar(getString('appTopBarAddBTP'), null),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AddBTPSearch(searchWithFilters),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getAddBTPPageBTPs(search, filters, ordering),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                      children: List.generate(
                          5,
                          (index) => const AddBTPInvestmentComponent(
                              investmentName: null,
                              investmentDetail: null,
                              cedola: null,
                              investmentValue: null,
                              variation: null)));
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Handle errors
                } else if (snapshot.hasData) {
                  final assets = snapshot.data!;
                  final investmentList = assets.map((asset) {
                    final name = processString(asset['name'] ?? 'N/A');
                    // final percentage = name[0];
                    final withBtp = name[1];
                    final btpLess = name[2];
                    final double value = asset['value'];
                    final double cedola = asset['cedola'];
                    var variation = (value - 100);
                    // make it have 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(3));

                    return TextButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          overlayColor: MaterialStateProperty.all(
                              primaryColor.withOpacity(0.3)),
                          shape: MaterialStateProperty.all(
                              const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero)),
                        ),
                        child: AddBTPInvestmentComponent(
                          investmentName: btpLess ?? "Unknown",
                          investmentDetail: "$withBtp",
                          cedola: "${cedola * 2}%",
                          investmentValue: value,
                          variation: variation,
                        ));
                  }).toList();
                  return Column(children: investmentList);
                } else {
                  return const Text('No data'); // Handle the case of no data
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
