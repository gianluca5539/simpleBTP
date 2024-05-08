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
  final DateTime? expirationDate;

  const WalletPageInvestmentComponent(
      {super.key,
      required this.investmentName,
      required this.investmentDetail,
      required this.cedola,
      required this.investmentValue,
      required this.variation,
      required this.expirationDate});

  String get cedolaRemainingDays {
    final DateTime now = DateTime.now();

    final DateTime cedolaDate1 = DateTime(
        now.year, expirationDate?.month ?? 1, expirationDate?.day ?? 1);

    DateTime cedolaDate0;
    // subtract 6 months from cedolaDate1
    if (cedolaDate1.month > 6) {
      cedolaDate0 = DateTime(cedolaDate1.year, cedolaDate1.month - 6,
          cedolaDate1.day); // subtract 6 months
    } else {
      cedolaDate0 = DateTime(cedolaDate1.year - 1, cedolaDate1.month + 6,
          cedolaDate1.day); // subtract 6 months
    }
    DateTime cedolaDate2;
    // add 6 months to cedolaDate1
    if (cedolaDate1.month < 6) {
      cedolaDate2 = DateTime(cedolaDate1.year, cedolaDate1.month + 6,
          cedolaDate1.day); // add 6 months
    } else {
      cedolaDate2 = DateTime(cedolaDate1.year + 1, cedolaDate1.month - 6,
          cedolaDate1.day); // add 6 months
    }

    List<DateTime> cedoleDates = [
      cedolaDate0,
      cedolaDate1,
      cedolaDate2
    ]; // next 3 cedole dates sorted

    Duration remainingTime = cedoleDates
        .where((element) => element.isAfter(now))
        .first
        .difference(now);

    return formatRemainingTime(remainingTime);
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
