import 'package:flutter/material.dart';
import 'package:hci_frontend/HomePage/balancecomponent.dart';
import 'package:hci_frontend/HomePage/homebestbtpscomponent.dart';
import 'package:hci_frontend/HomePage/homemyassetscomponent.dart';
import 'package:hci_frontend/assets/colors.dart';
import 'package:hci_frontend/btp_scraper.dart';
import 'package:hci_frontend/components/AppTopBar/apptopbar.dart';
import 'package:hci_frontend/components/Footer/footer.dart';
import 'package:hci_frontend/db/db.dart';

import 'btp_component.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhiteColor,
      appBar: AppTopBar('simpleBTP'),
      body: SingleChildScrollView(
        // To ensure the list is scrollable
        child: Column(
          children: [
            FutureBuilder<Map<String, double>>(
                future: getWalletStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return BalanceComponent(balance: null, variation: null);
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Handle errors
                  } else if (snapshot.hasData) {
                    double balance = snapshot.data!['balance']!;
                    double variation = snapshot.data!['variation']!;
                    // limit variation to 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(2));
                    return BalanceComponent(
                        balance: balance, variation: variation);
                  }
                  return const Text('No data'); // Handle the case of no data
                }),
            const HomeMyAssetsComponent(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getHomePageMyBestBTPs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator
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
                    double variation = asset['variation'];
                    // fix variation to have 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(3));

                    return InvestmentComponent(
                      investmentName: btpLess ??
                          "Unknown", // Replace with actual key if exists
                      investmentDetail:
                          "$withBtp\n${cedola * 2}%", // Replace with actual keys if exists
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
                  return const CircularProgressIndicator(); // Show loading indicator
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

                    return InvestmentComponent(
                      investmentName: btpLess ??
                          "Unknown", // Replace with actual key if exists
                      investmentDetail:
                          "$withBtp\n${cedola * 2}%", // Replace with actual keys if exists
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
