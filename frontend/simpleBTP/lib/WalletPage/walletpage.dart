import 'package:flutter/material.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar('Portafoglio'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMyBTPHistories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return const Center(
              child: Icon(Icons.account_balance_wallet), // Example icon, replace with your actual widget
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
      bottomNavigationBar: Footer('wallet'),
    );
  }
}
