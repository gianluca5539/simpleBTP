import 'package:flutter/material.dart';
import 'package:simpleBTP/WalletPage/walletpagebalancecomponent.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:simpleBTP/db/db.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar('Portafoglio'),
      body: Column(
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
          )
        ],
      ),
      bottomNavigationBar: Footer('wallet'),
    );
  }
}
