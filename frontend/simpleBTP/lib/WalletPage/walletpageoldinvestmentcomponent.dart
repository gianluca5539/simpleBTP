import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalletPageOldInvestmentComponent extends StatelessWidget {
  final String? investmentName;
  final double? investmentValue;
  final DateTime? investmentSoldDate;
  final double? investmentProfit;

  const WalletPageOldInvestmentComponent(
      {super.key, required this.investmentName, required this.investmentValue, required this.investmentSoldDate, required this.investmentProfit});

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Skeletonizer(
      enabled: investmentName == null,
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
                      color: Colors.grey, // This color should match the background of the label in your image.
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      investmentName?.toUpperCase() ?? "",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                  ),
                  Text(
                    investmentSoldDate == null
                        ? '----'
                        : 'Sold on: ${investmentSoldDate!.day > 10 ? "${investmentSoldDate!.day}" : "0${investmentSoldDate!.day}"}/${investmentSoldDate!.month > 10 ? "${investmentSoldDate!.month}" : "0${investmentSoldDate!.month}"}/${investmentSoldDate!.year},',
                    style: TextStyle(color: isDarkMode ? lightTextColor : textColor, fontSize: 15),
                  ),
                  Text(
                    'Final value: €${(investmentProfit ?? 0).toStringAsFixed(2)}',
                    style: TextStyle(color: isDarkMode ? lightTextColor : textColor, fontSize: 15),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${(investmentValue ?? 0) > 0 ? '+' : (investmentValue ?? 0) < 0 ? '-' : ''}€${investmentValue?.abs().toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}",
                  style: TextStyle(
                    color: (investmentValue ?? 0) > 0
                        ? Colors.green
                        : (investmentValue ?? 0) < 0
                            ? Colors.red
                            : Colors.grey,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 17,
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
            )
          ],
        ),
      ),
    );
  }
}
