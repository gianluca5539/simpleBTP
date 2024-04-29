import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalletPageBalanceComponent extends StatelessWidget {
  final double? balance;
  final double? variation;

  const WalletPageBalanceComponent(
      {super.key, required this.balance, required this.variation});

  @override
  Widget build(BuildContext context) {
    // Assume each label is about 60 pixels wide, change this based on your font size and style
    double labelWidth = 60;
    // Get the width of the chart
    double chartWidth = MediaQuery.of(context).size.width *
        0.9; // Since you're using 0.9 of screen width
    // Calculate the number of labels that could fit
    int numLabelsThatFit = chartWidth ~/ labelWidth;
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
                if (variation != null)
                FutureBuilder<Map<DateTime, double>>(
                  future: createPortfolioValueGraph(TimeWindow.oneYear),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      // Determine minY and maxY for padding
                      final double minY = snapshot.data!.values.isNotEmpty
                          ? (snapshot.data!.values.reduce(min) *
                              0.95) // 5% padding at bottom
                          : 0;
                      final double maxY = snapshot.data!.values.isNotEmpty
                          ? (snapshot.data!.values.reduce(max) *
                              1.05) // 5% padding at top
                          : 0;

                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 25, 40, 15),
                        child: AspectRatio(
                          aspectRatio: 1.0, // To make the chart square
                          child: LineChart(
                            LineChartData(
                              minY: minY,
                              maxY: maxY,
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
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: false), // No right titles
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: false), // No top titles
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1, // Start with an interval of 1
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      final dates = snapshot.data!.keys.toList()
                                        ..sort();
                                      // Calculate the actual interval based on the data length and the number of labels that fit
                                      int actualInterval = max(
                                          1, dates.length ~/ numLabelsThatFit);
                                      if (value.toInt() % actualInterval == 0) {
                                        DateTime date = dates[value.toInt()];
                                        String formattedDate =
                                            DateFormat('yy/MM/dd').format(date);
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Text(formattedDate,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10)),
                                        );
                                      }
                                      return const Text('');
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget:
                                        (double value, TitleMeta meta) {
                                      if (value == minY) {
                                        return const Text('');
                                      }
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
    final dates = data.keys.toList()..sort(); // Ensure the dates are sorted
    return dates
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), data[entry.value]!))
        .toList();
  }
}
