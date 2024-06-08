import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:simpleBTP/assets/colors.dart'; // Adjust the path if necessary
import 'package:simpleBTP/assets/languages.dart'; // Adjust the path if necessary

class TransactionComponent extends StatelessWidget {
  final String? isin;
  final String? name;
  final String? type;
  final double? price;
  final int? amount;
  final DateTime? date;

  const TransactionComponent({
    super.key,
    required this.isin,
    required this.name,
    required this.type,
    required this.price,
    required this.amount,
    required this.date,
  });

  String get formattedDate {
    if (date == null) return '----';
    return '${date!.day > 9 ? date!.day : "0${date!.day}"}/${date!.month > 9 ? date!.month : "0${date!.month}"}/${date!.year}';
  }

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    bool isBuy = type?.toLowerCase() == 'buy';
    Color priceColor = isBuy ? Colors.red : Colors.green;

    return Skeletonizer(
      enabled: name == null,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.fromLTRB(25, 13, 10, 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      name?.toUpperCase() ?? "",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isBuy ? 'Bought on: $formattedDate' : 'Sold on: $formattedDate',
                    style: TextStyle(
                      color: isDarkMode ? lightTextColor : textColor,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Amount: ${amount ?? "----"}',
                    style: TextStyle(
                      color: isDarkMode ? lightTextColor : textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isBuy ? '-€${price?.toStringAsFixed(2).replaceAll(".", ",") ?? "----"}' : '€${price?.toStringAsFixed(2).replaceAll(".", ",") ?? "----"}',
                  style: TextStyle(
                    color: priceColor,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 17),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
