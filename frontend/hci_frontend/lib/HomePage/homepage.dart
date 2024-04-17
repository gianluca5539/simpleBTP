import 'package:flutter/material.dart';
import 'package:hci_frontend/HomePage/balancecomponent.dart';
import 'package:hci_frontend/WalletPage/walletpage.dart';
import 'package:hci_frontend/components/AppTopBar/apptopbar.dart';
import 'package:hci_frontend/components/Footer/footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // off white background
      backgroundColor: Color.fromARGB(255, 248, 248, 248),
      appBar: AppTopBar('BTP Genius'),
      // add a body and a footer
      body: Column(
        children: [
          BalanceComponent(balance: 131231.22, variation: 1.12),
        ],
      ),
      bottomNavigationBar: Footer('home'),
    );
  }
}
