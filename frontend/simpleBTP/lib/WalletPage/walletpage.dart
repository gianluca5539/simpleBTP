import 'package:flutter/material.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar('Portafoglio'),
      // add a body and a footer
      body: const Center(
        child: Icon(Icons.account_balance_wallet),
      ),
      bottomNavigationBar: Footer('wallet'),
    );
  }
}
