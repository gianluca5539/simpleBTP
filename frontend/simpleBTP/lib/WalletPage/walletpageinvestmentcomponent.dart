import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/components/OldBTPDetail/my_old_btp_detail.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalletPageInvestmentComponent extends StatelessWidget {
  final String? investmentName;
  final String? investmentDetail;
  final double? cedola;
  final double? investmentValue;
  final double? variation;
  final DateTime? expirationDate;
  final int? investmentAmount;
  final double? buyPrice;
  final DateTime? buyDate;

  const WalletPageInvestmentComponent(
      {super.key,
      required this.investmentName,
      required this.investmentDetail,
      required this.cedola,
      required this.investmentValue,
      required this.variation,
      required this.expirationDate,
      required this.investmentAmount,
      required this.buyPrice,
      required this.buyDate});

  String get cedolaRemainingDays {
    final DateTime now = DateTime.now();

    final DateTime cedolaDate1 = DateTime(now.year, expirationDate?.month ?? 1, expirationDate?.day ?? 1);

    DateTime cedolaDate0;
    // subtract 6 months from cedolaDate1
    if (cedolaDate1.month > 6) {
      cedolaDate0 = DateTime(cedolaDate1.year, cedolaDate1.month - 6, cedolaDate1.day); // subtract 6 months
    } else {
      cedolaDate0 = DateTime(cedolaDate1.year - 1, cedolaDate1.month + 6, cedolaDate1.day); // subtract 6 months
    }
    DateTime cedolaDate2;
    // add 6 months to cedolaDate1
    if (cedolaDate1.month < 6) {
      cedolaDate2 = DateTime(cedolaDate1.year, cedolaDate1.month + 6, cedolaDate1.day); // add 6 months
    } else {
      cedolaDate2 = DateTime(cedolaDate1.year + 1, cedolaDate1.month - 6, cedolaDate1.day); // add 6 months
    }

    List<DateTime> cedoleDates = [cedolaDate0, cedolaDate1, cedolaDate2]; // next 3 cedole dates sorted

    DateTime remainingTime = cedoleDates.where((element) => element.isAfter(now)).first;

    return '${remainingTime.day > 10 ? remainingTime.day : "0${remainingTime.day}"}/${remainingTime.month > 10 ? remainingTime.month : "0${remainingTime.month}"}/${remainingTime.year.toString().substring(2)}';
  }

  bool get timeToSell {
    if (cedola == null) {
      return false;
    }
    return getMyBTPProfitabilityNow(investmentValue! / investmentAmount!, buyPrice!, cedola!, buyDate!) /
            getMyBTPProfitabilityAtExpiration(buyPrice!, cedola!, expirationDate!, buyDate!) >
        0.4;
  }

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
                  Row(
                    children: [
                      Container(
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: primaryColor, // This color should match the background of the label in your image.
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          investmentName?.toUpperCase() ?? "",
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      if (timeToSell)
                        Container(
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.red[400], // This color should match the background of the label in your image.
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Consider selling",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),

                      // check if the investment is new, made in last week
                      if (buyDate != null && DateTime.now().difference(buyDate!).inDays < 7)
                        Container(
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.green[400], // This color should match the background of the label in your image.
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "Just bought",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    cedola != null && investmentAmount != null ? '${getString('walletPaysWhat')} €${cedola! * investmentAmount!} on:' : '----',
                    style: TextStyle(color: isDarkMode ? lightTextColor : textColor, fontSize: 16),
                  ),
                  Text(
                    cedolaRemainingDays,
                    style: TextStyle(color: isDarkMode ? lightTextColor : textColor, fontSize: 16),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "€${investmentValue?.toStringAsFixed(2).replaceAll(".", ",").replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}",
                  style: TextStyle(color: isDarkMode ? lightTextColor : textColor, fontSize: 22),
                ),
                Text(
                  "${(variation ?? 0) > 0 ? "▲" : (variation ?? 0) < 0 ? "▼" : "— "} $variation%",
                  style: TextStyle(
                    color: (variation ?? 0) > 0
                        ? Colors.green
                        : (variation ?? 0) < 0
                            ? Colors.red
                            : Colors.grey,
                    fontSize: 18,
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
