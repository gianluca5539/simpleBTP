import 'package:flutter/material.dart';
import 'package:simpleBTP/TransactionPage/transactioncomponent.dart';
import 'package:simpleBTP/db/db.dart';
import 'package:simpleBTP/assets/colors.dart'; // Adjust the path if necessary

class TransactionPage extends StatelessWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: primaryColor, // Adjust to match your app's theme
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No transactions found'),
            );
          } else {
            final transactions = snapshot.data!;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return TransactionComponent(
                  isin: transaction['isin'],
                  name: transaction['name'],
                  type: transaction['type'],
                  price: transaction['price'],
                  amount: transaction['amount'],
                  date: transaction['date'],
                );
              },
            );
          }
        },
      ),
    );
  }
}
