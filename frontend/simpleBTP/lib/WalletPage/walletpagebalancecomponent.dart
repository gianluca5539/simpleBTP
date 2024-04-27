import 'package:fl_chart/fl_chart.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalletPageBalanceComponent extends StatelessWidget {
  late double? balance;
  late double? variation;

  WalletPageBalanceComponent(
      {super.key, required this.balance, required this.variation});

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Center(
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
              ]),
          width: 0.9 * MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
            child: Column(
              // align text to the left
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 17.0, right: 17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getString('walletBalanceText'),
                        style: TextStyle(
                            color: isDarkMode ? lightTextColor : textColor,
                            fontSize: 22),
                      ),
                      Skeletonizer(
                          enabled: variation == null,
                          child: Text(
                            "${variation?.toStringAsFixed(2)}%",
                            style: TextStyle(
                                color: (variation ?? 0) > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 22),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 17.0, right: 17.0, top: 5.0),
                  child: Skeletonizer(
                      enabled: balance == null,
                      child: Text(
                        "€${balance == null ? '----' : ''}${balance?.toStringAsFixed(2).replaceAll(".", ",").replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}",
                        style: TextStyle(
                            color: isDarkMode ? lightTextColor : textColor,
                            fontSize: 34),
                      )),
                ),
                FutureBuilder<Map<DateTime, double>>(
                  future: createPortfolioValueGraph(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AspectRatio(
                          aspectRatio: 1.0, // To make the chart square
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                drawHorizontalLine: true,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey[300],
                                  strokeWidth: 1,
                                ),
                                getDrawingVerticalLine: (value) => FlLine(
                                  color: Colors.grey[300],
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      // Customizing the text for bottom titles
                                      return Text(value.toInt().toString(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12));
                                    },
                                    reservedSize: 22,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      // Customizing the text for left titles
                                      return Text('${value.toInt()}€',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12));
                                    },
                                    reservedSize: 40, // Adjust as needed
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: false,
                                  dotData: const FlDotData(
                                      show: false), // Hide the dots
                                  color: Theme.of(context).primaryColor,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(
                                            0.3), // The fill color with some opacity
                                  ),
                                  spots: _getSpots(snapshot.data!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: Text('No data found'));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(Map<DateTime, double> data) {
    return data.entries
        .map((entry) => FlSpot(entry.key.day.toDouble(), entry.value))
        .toList();
  }
}
