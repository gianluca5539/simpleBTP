import 'package:flutter/material.dart';
import 'package:hci_frontend/WalletPage/walletpage.dart';
import 'package:hci_frontend/components/AppTopBar/apptopbar.dart';
import 'package:hci_frontend/components/Footer/footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar('BTP Genius'),
      // add a body and a footer
      body: const Center(child: Icon(Icons.home)),
      bottomNavigationBar: Footer('home'),
    );
  }
}