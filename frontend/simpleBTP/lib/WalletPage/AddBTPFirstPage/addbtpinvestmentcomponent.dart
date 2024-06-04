import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddBTPInvestmentComponent extends StatelessWidget {
  final String? investmentName;
  final String? investmentDetail;
  final String? cedola;
  final double? investmentValue;
  final double? variation;

  const AddBTPInvestmentComponent({
    super.key,
    required this.investmentName,
    required this.investmentDetail,
    required this.cedola,
    required this.investmentValue,
    required this.variation,
  });

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
                  Text(
                    investmentDetail?.toUpperCase() ?? '----------',
                    style: TextStyle(
                        color: isDarkMode ? lightTextColor : textColor,
                        fontSize: 16),
                  ),
                  Text(
                    cedola ?? '----',
                    style: TextStyle(
                        color: isDarkMode ? lightTextColor : textColor,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "€${investmentValue?.toStringAsFixed(2).replaceAll(".", ",")}",
                  style: TextStyle(
                      color: isDarkMode ? lightTextColor : textColor,
                      fontSize: 20),
                ),
                Text(
                  "${(variation ?? 0) > 0 ? "▲" : "▼"} $variation%",
                  style: TextStyle(
                    color: (variation ?? 0) > 0 ? Colors.green : Colors.red,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Icon(Icons.arrow_forward_ios_outlined, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
