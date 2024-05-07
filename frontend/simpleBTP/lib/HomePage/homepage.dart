import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/HomePage/homepagebalancecomponent.dart';
import 'package:simpleBTP/HomePage/homebestbtpscomponent.dart';
import 'package:simpleBTP/HomePage/homemyassetscomponent.dart';
import 'package:simpleBTP/HomePage/homepageinvestmentcomponent.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';
import 'package:simpleBTP/db/db.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : offWhiteColor,
      appBar: AppTopBar(getString('appTopBarHome'), null),
      body: SingleChildScrollView(
        // To ensure the list is scrollable
        child: Column(
          children: [
            FutureBuilder<Map<String, double>>(
                future: getWalletStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return HomePageBalanceComponent(
                        balance: null, variation: null);
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Handle errors
                  } else if (snapshot.hasData) {
                    double balance = snapshot.data!['balance']!;
                    double variation = snapshot.data!['variation']!;
                    // limit variation to 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(2));
                    return HomePageBalanceComponent(
                        balance: balance, variation: variation);
                  }
                  return const Text('No data'); // Handle the case of no data
                }),
            const HomeMyAssetsComponent(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getHomePageMyBestBTPs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: List.generate(
                        2,
                        (index) => const HomePageInvestmentComponent(
                            investmentName: null,
                            investmentDetail: null,
                            cedola: null,
                            investmentValue: null,
                            variation: null)),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Handle errors
                } else if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Text(
                      getString('homePageNoBTPsYet'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: isDarkMode ? lightTextColor : textColor),
                    );
                  }
                  final assets = snapshot.data!;
                  final investmentList = assets.map((asset) {
                    final name = processString(asset['name'] ?? 'N/A');
                    // final percentage = name[0];
                    final withBtp = name[1];
                    final btpLess = name[2];
                    final double value = asset['value'];
                    final double cedola = asset['cedola'];
                    double variation = asset['variation'];
                    // fix variation to have 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(3));

                    return HomePageInvestmentComponent(
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
            const HomeBestBTPsComponent(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getHomePageBestBTPs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                      children: List.generate(
                          5,
                          (index) => const HomePageInvestmentComponent(
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

                    return HomePageInvestmentComponent(
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
      bottomNavigationBar: Footer('home'),
    );
  }
}
