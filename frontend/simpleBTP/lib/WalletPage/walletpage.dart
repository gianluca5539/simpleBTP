import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpfirstpage.dart';
import 'package:simpleBTP/WalletPage/walletpageinvestmentcomponent.dart';
import 'package:simpleBTP/WalletPage/walletpagebalancecomponent.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';
import 'package:simpleBTP/db/db.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : offWhiteColor,
      appBar: AppTopBar(getString('appTopBarWallet'), {
        'icon': Icons.add,
        'onPressed': () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddBTPFirstPage()));
        },
      }),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: FutureBuilder<Map<String, double>>(
                  future: getWalletStats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return WalletPageBalanceComponent(
                          balance: null, variation: null);
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // Handle errors
                    } else if (snapshot.hasData) {
                      double balance = snapshot.data!['balance']!;
                      double variation = snapshot.data!['variation']!;
                      // limit variation to 3 decimal places
                      variation = double.parse(variation.toStringAsFixed(2));
                      return WalletPageBalanceComponent(
                          balance: balance, variation: variation);
                    }
                    return const Text('No data'); // Handle the case of no data
                  }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                getString('walletMyAssets'),
                style: TextStyle(
                    fontSize: 24,
                    color: isDarkMode ? lightTextColor : textColor),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getWalletPageMyBTPs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: List.generate(
                        2,
                        (index) => const WalletPageInvestmentComponent(
                            investmentName: null,
                            investmentDetail: null,
                            cedola: null,
                            investmentValue: null,
                        variation: null,
                        buyDate: null,
                      ),
                    ),
                  );
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
                    final date = asset['buyDate'];

                    return WalletPageInvestmentComponent(
                      investmentName: btpLess ?? "Unknown",
                      investmentDetail: "$withBtp",
                      cedola: "$cedola%",
                      investmentValue: value,
                      variation: variation,
                      buyDate: date,
                    );
                  }).toList();
                  return Column(children: investmentList);
                } else {
                  return const Text('No data'); // Handle the case of no data
                }
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Footer('wallet'),
    );
  }
}
