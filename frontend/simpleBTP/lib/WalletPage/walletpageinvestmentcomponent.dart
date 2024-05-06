import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalletPageInvestmentComponent extends StatelessWidget {
  final String? investmentName;
  final String? investmentDetail;
  final String? cedola;
  final double? investmentValue;
  final double? variation;
  final DateTime? buyDate;

  const WalletPageInvestmentComponent({
    super.key,
    required this.investmentName,
    required this.investmentDetail,
    required this.cedola,
    required this.investmentValue,
    required this.variation,
    required this.buyDate,
  });

  String get cedolaRemainingDays {
    if (buyDate == null) {
      return '----';
    }
    final DateTime now = DateTime.now();

    // bring the buy date to this year
    final DateTime buyDateThisYear =
        DateTime(now.year, buyDate!.month, buyDate!.day);

    // subtract 6 months from the buy date
    final DateTime buyDateThisYearMinus6Months =
        buyDateThisYear.subtract(const Duration(days: 180));

    // add 6 months to the buy date
    final DateTime buyDateThisYearPlus6Months =
        buyDateThisYear.add(const Duration(days: 180));

    if (now.isBefore(buyDateThisYearMinus6Months)) {
      return formatRemainingTime(buyDateThisYearMinus6Months.difference(now));
    } else if (now.isAfter(buyDateThisYearMinus6Months) &&
        now.isBefore(buyDateThisYear)) {
      return formatRemainingTime(buyDateThisYear.difference(now));
    } else if (now.isAfter(buyDateThisYear) &&
        now.isBefore(buyDateThisYearPlus6Months)) {
      return formatRemainingTime(buyDateThisYearPlus6Months.difference(now));
    } else {
      return '----';
    }
  }

  String formatRemainingTime(Duration remainingTime) {
    int diffMonths = remainingTime.inDays ~/ 30;
    int diffDays = remainingTime.inDays % 30;
    return diffMonths > 0
        ? '$diffMonths ${getString(
            'months',
          )} ${getString('and')} $diffDays ${getString('days')}'
        : '$diffDays ${getString('days')}';
  }

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Skeletonizer(
        enabled: investmentName == null,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isDarkMode ? darkModeColor : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(25, 13, 30, 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color:
                            primaryColor, // This color should match the background of the label in your image.
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        investmentName?.toUpperCase() ?? "",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                    ),
                    Text(
                      cedola != null
                          ? '${getString('walletPaysWhat')} $cedola ${getString('walletPaysIn')}:'
                          : '----',
                      style: TextStyle(
                          color: isDarkMode ? lightTextColor : textColor,
                          fontSize: 16),
                    ),
                    Text(
                      cedolaRemainingDays,
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
                    "€${investmentValue?.toStringAsFixed(2).replaceAll(".", ",").replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}",
                    style: TextStyle(
                        color: isDarkMode ? lightTextColor : textColor,
                        fontSize: 22),
                  ),
                  Text(
                    "${(variation ?? 0) > 0 ? "▲" : "▼"} $variation%",
                    style: TextStyle(
                      color: (variation ?? 0) > 0 ? Colors.green : Colors.red,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
