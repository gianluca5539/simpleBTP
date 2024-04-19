import 'package:flutter/material.dart';
import 'package:hci_frontend/HomePage/balancecomponent.dart';
import 'package:hci_frontend/HomePage/homebestbtpscomponent.dart';
import 'package:hci_frontend/HomePage/homemyassetscomponent.dart';
import 'package:hci_frontend/assets/colors.dart';
import 'package:hci_frontend/btp_scraper.dart';
import 'package:hci_frontend/components/AppTopBar/apptopbar.dart';
import 'package:hci_frontend/components/Footer/footer.dart';

import 'btp_component.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhiteColor,
      appBar: AppTopBar('simpleBTP'),
      body: SingleChildScrollView( // To ensure the list is scrollable
        child: Column(
          children: [
            BalanceComponent(balance: 131231.22, variation: 1.12),
            const HomeMyAssetsComponent(),
            FutureBuilder<Map<String, Map<String, String>>>(
              future: fetchBtps(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Handle errors
                } else if (snapshot.hasData) {
                  final assets = snapshot.data!;
                  final investmentList = assets.keys.map((key) {
                    final asset = assets[key]!;
                    final name = processString(asset['btp'] ?? 'N/A');
                    // final percentage = name[0];
                    final withBtp = name[1];
                    final btpLess = name[2];
                    var ultimo = asset['ultimo'] ?? '0';
                    var cedola = asset['cedola'] ?? '0';
                    ultimo = ultimo.replaceAll(',', '.');
                    cedola = cedola.replaceAll(',', '.');
                    final double ultimoDouble = double.tryParse(ultimo) ?? 0.0;
                    final double cedolaDouble = double.tryParse(cedola) ?? 0.0;
                    var variation = (ultimoDouble - 100);
                    // make it have 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(3));

                    return InvestmentComponent(
                      investmentName: btpLess ??
                          "Unknown", // Replace with actual key if exists
                      investmentDetail:
                          "$withBtp\n${cedolaDouble * 2}%", // Replace with actual keys if exists
                      investmentValue: ultimoDouble,
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
            FutureBuilder<Map<String, Map<String, String>>>(
              future: fetchBtps(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Handle errors
                } else if (snapshot.hasData) {
                  final assets = snapshot.data!;
                  final investmentList = assets.keys.map((key) {
                    final asset = assets[key]!;
                    final name = processString(asset['btp'] ?? 'N/A');
                    // final percentage = name[0];
                    final withBtp = name[1];
                    final btpLess = name[2];
                    var ultimo = asset['ultimo'] ?? '0';
                    var cedola = asset['cedola'] ?? '0';
                    ultimo = ultimo.replaceAll(',', '.');
                    cedola = cedola.replaceAll(',', '.');
                    final double ultimoDouble = double.tryParse(ultimo) ?? 0.0;
                    final double cedolaDouble = double.tryParse(cedola) ?? 0.0;
                    var variation = (ultimoDouble - 100);
                    // make it have 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(3));

                    return InvestmentComponent(
                      investmentName: btpLess ?? "Unknown", // Replace with actual key if exists
                      investmentDetail: "$withBtp\n${cedolaDouble*2}%", // Replace with actual keys if exists
                      investmentValue: ultimoDouble,
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
