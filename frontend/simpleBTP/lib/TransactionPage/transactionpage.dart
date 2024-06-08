import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/TransactionPage/transactioncomponent.dart';
import 'package:simpleBTP/db/db.dart';
import 'package:simpleBTP/assets/colors.dart'; // Adjust the path if necessary

class TransactionPage extends StatelessWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text('Transactions', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                primaryColor,
                secondaryColor,
              ],
            ),
          ),
        ),
        
      ),
      body: Container(
        color: isDarkMode ? offBlackColor : Colors.white54,
        child: FutureBuilder<List<Map<String, dynamic>>>(
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
                  return Column(
                    children: [
                      TransactionComponent(
                        isin: transaction['isin'],
                        name: transaction['name'],
                        type: transaction['type'],
                        price: transaction['price'],
                        amount: transaction['amount'],
                        date: transaction['date'],
                      ),
                      Divider(height: 1, color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
