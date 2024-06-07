import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/components/OldBTPDetail/my_old_btp_detail.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddBTPInvestmentComponent extends StatelessWidget {
  final String? investmentName;
  final String? investmentDetail;
  final double? cedola;
  final double? investmentValue;
  final double? variation;
  final DateTime? expirationDate;

  const AddBTPInvestmentComponent({
    super.key,
    required this.investmentName,
    required this.investmentDetail,
    required this.cedola,
    required this.investmentValue,
    required this.variation,
    required this.expirationDate,
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
                    style: const TextStyle(
                        color: primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${cedola != null ? cedola! * 2 : '-'}%",
                    
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Profit: ',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      cedola != null
                          ? '${getMyBTPProfitabilityAtExpiration(investmentValue!, cedola!, expirationDate!, DateTime.now()).toStringAsFixed(2)}%'
                          : '',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 15,
                      ),
                    ),
                  ],
                )
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
