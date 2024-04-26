import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/ExplorePage/explorepageinvestmentcomponent.dart';
import 'package:simpleBTP/ExplorePage/explorepagesearchandfiltercomponent.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';
import 'package:simpleBTP/db/db.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String search = '';

  Map<String, dynamic> filters = defaultExploreFilters;

  Map<String, dynamic> ordering = defaultExploreOrdering;

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
      backgroundColor: isDarkMode ? offBlackColor : offWhiteColor,
      appBar: AppTopBar(
        getString('appTopBarExplore'), null
      ),
      // add a body and a footer
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExplorePageSearchAndFilterComponent(searchWithFilters),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getExplorePageBTPs(search, filters, ordering),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                      children: List.generate(
                          5,
                          (index) => const ExplorePageInvestmentComponent(
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

                    return ExplorePageInvestmentComponent(
                      investmentName: btpLess ?? "Unknown",
                      investmentDetail: "$withBtp",
                      cedola: "${cedola * 2}%",
                      investmentValue: value,
                      variation: variation,
                    );
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
      bottomNavigationBar: Footer('explore'),
    );
  }
}
