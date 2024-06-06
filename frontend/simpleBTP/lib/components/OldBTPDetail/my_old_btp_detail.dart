import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/db/hivemodels.dart';

// Cache to store graph data
Map<String, Map<TimeWindow, Map<DateTime, double>>> graphDataCache = {};
TimeWindow timeWindow = TimeWindow.oneWeek;

double getMyBTPProfitabilityAtExpiration(
    double buyPrice, double cedola, DateTime expirationDate, DateTime buyDate) {
  var finalValue = (100 - buyPrice) * 100 / buyPrice;
  // check how many years are left
  int cedolaPayments = 0;
  while (buyDate.isBefore(expirationDate)) {
    cedolaPayments++;
    // take 6 months from the expiration date
    if (expirationDate.month > 6) {
      expirationDate = DateTime(
          expirationDate.year, expirationDate.month - 6, expirationDate.day);
    } else {
      expirationDate = DateTime(expirationDate.year - 1,
          expirationDate.month + 6, expirationDate.day);
    }
  }
  double totalCedola = cedolaPayments * cedola;
  double totalProfit = totalCedola + finalValue;
  return totalProfit;
}

double getMyBTPProfitabilityNow(
    double value, double buyPrice, double cedola, DateTime buyDate) {
  double cedoleCount = -1;
  DateTime now = DateTime.now();
  while (buyDate.isBefore(now)) {
    cedoleCount++;
    now = now.subtract(const Duration(days: 365));
  }

  double cedoleProfit = cedoleCount * cedola;

  return (((value * 1) + cedoleProfit) / (buyPrice * 1)) * 100 - 100;
}

Future<Map<DateTime, double>?> getCachedGraphData(
    String isin, TimeWindow timeWindow) async {
  if (graphDataCache.containsKey(isin) &&
      graphDataCache[isin]!.containsKey(timeWindow)) {
    //print('Cached data found for $isin');
    return graphDataCache[isin]?[timeWindow]!;
  } else {
    //print('No cached data found for $isin');
    return createSingleBtpValueGraph(isin, timeWindow).then((value) {
      graphDataCache.putIfAbsent(isin, () => {})[timeWindow] = value;
      //print('Cached data for $isin');
      return value;
    });
  }
}

List<FlSpot> getSpots(Map<DateTime, double> data) {
  final dates = data.keys.toList()..sort(); // Ensure the dates are sorted
  return dates
      .asMap()
      .entries
      .map((entry) => FlSpot(entry.key.toDouble(), data[entry.value]!))
      .toList();
}

void openMyOldBTPDetailModal(
    BuildContext context,
    isDarkMode,
    BTP btp,
    double buyPrice,
    double soldPrice,
    int investment,
    DateTime buyDate,
    DateTime soldDate,
    double cedole) {
  // Assume each label is about 60 pixels wide, change this based on your font size and style
  double labelWidth = 80;
  // Get the width of the chart
  double chartWidth = MediaQuery.of(context).size.width *
      0.9; // Since you're using 0.9 of screen width
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? offBlackColor : offWhiteColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 80,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDarkMode ? darkModeColor : Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    btp.name.toUpperCase(),
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? primaryColorLight : primaryColor),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? darkModeColor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getString('Sold Price'),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  soldPrice.toString(),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(
                              color: isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getString('WalletPageBTPInformationBuyPrice'),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  buyPrice.toString(),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(
                              color: isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getString('Sold date'),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${soldDate.day < 10 ? '0' : ''}${soldDate.day}/${btp.expirationDate.month < 10 ? '0' : ''}${soldDate.month}/${soldDate.year}',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(
                              color: isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getString('WalletPageBTPInformationBuyDate'),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${buyDate.day < 10 ? '0' : ''}${buyDate.day}/${buyDate.month < 10 ? '0' : ''}${buyDate.month}/${buyDate.year}',
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(
                              color: isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getString('ExplorePageBTPInformationISIN'),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  btp.isin,
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(
                              color: isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getString('Investment'),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '€${buyPrice * investment}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              color: isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[200],
                              thickness: 1,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getString('Final value'),
                                  style: TextStyle(
                                      color: isDarkMode
                                          ? lightTextColor
                                          : textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '€${(investment * soldPrice + cedole).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ]),
            ),
          );
        });
      });
}
