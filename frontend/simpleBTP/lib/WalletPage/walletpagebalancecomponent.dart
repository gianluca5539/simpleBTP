import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WalletPageBalanceComponent extends StatefulWidget {
  final double? balance;
  final double? variation;

  const WalletPageBalanceComponent({super.key, required this.balance, required this.variation});

  @override
  State<WalletPageBalanceComponent> createState() =>
      _WalletPageBalanceComponentState();
}

class _WalletPageBalanceComponentState
    extends State<WalletPageBalanceComponent> {
  TimeWindow timeWindow = TimeWindow.oneWeek;
  
  
  @override
  Widget build(BuildContext context) {
    // Assume each label is about 60 pixels wide, change this based on your font size and style
    double labelWidth = 80;
    // Get the width of the chart
    double chartWidth = MediaQuery.of(context).size.width * 0.9; // Since you're using 0.9 of screen width
    // Calculate the number of labels that could fit
    int numLabelsThatFit = chartWidth ~/ labelWidth;
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    Color positiveColor = Colors.green.shade100; // Lighter green for positive variation
    Color negativeColor = Colors.red.shade100; // Lighter red for negative variation

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: isDarkMode ? darkModeColor : Colors.white, boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.transparent : Colors.grey.withOpacity(0.2),
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
                        style: TextStyle(color: isDarkMode ? lightTextColor : titleColor, fontSize: 20),
                      ),
                      Skeletonizer(
                        enabled: widget.variation == null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: (widget.variation ?? 0) > 0 ? positiveColor : negativeColor,
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          child: Text(
                            "${(widget.variation ?? 0) > 0 ? "▲" : "▼"} ${widget.variation?.toStringAsFixed(2)}%", 
                            style: TextStyle(
                              color: (widget.variation ?? 0) > 0 ? Colors.green : Colors.red,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 17.0, right: 17.0, top: 5.0),
                  child: Skeletonizer(
                      enabled: widget.balance == null,
                      child: Text(
                        "€${widget.balance == null ? '----' : ''}${widget.balance?.toStringAsFixed(2).replaceAll(".", ",").replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}",
                        style: TextStyle(color: isDarkMode ? lightTextColor : textColor, fontSize: 34, fontWeight: FontWeight.bold),
                      )),
                ),
                
                if (widget.variation != null)
                  FutureBuilder<Map<DateTime, double>>(
                    future: createPortfolioValueGraph(timeWindow),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CupertinoActivityIndicator(),
                                const SizedBox(height: 10),
                                Text('Loading the graph...',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    )),
                              ],
                            ),
                          )),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
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
                          padding: const EdgeInsets.fromLTRB(35, 0, 35, 0),
                          child: SizedBox(
                            height: 190, // To make the chart square
                            width: double.infinity,
                            child: LineChart(
                              LineChartData(
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipItems:
                                        (List<LineBarSpot> touchedSpots) {
                                      return touchedSpots
                                          .map((LineBarSpot touchedSpot) {
                                        final DateTime date = snapshot
                                            .data!.keys
                                            .toList()[touchedSpot.x.toInt()];
                                        final double value = touchedSpot.y;
                                        return LineTooltipItem(
                                          '€${value.toStringAsFixed(2).replaceAll(".", ",").replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}\n${DateFormat('dd/MM/yy').format(date)}',
                                          const TextStyle(
                                              color: lightTextColor),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                minY: minY,
                                maxY: maxY,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  drawHorizontalLine: true,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: isDarkMode
                                        ? Colors.grey[700]
                                        : Colors.grey[200],
                                    strokeWidth: 1,
                                  ),
                                  getDrawingVerticalLine: (value) => FlLine(
                                    color: Colors.grey[200],
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
                                      showTitles: false,
                                      interval:
                                          1, // Start with an interval of 1
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        final dates = snapshot.data!.keys
                                            .toList()
                                          ..sort();
                                        // Calculate the actual interval based on the data length and the number of labels that fit
                                        int actualInterval = max(1,
                                            dates.length ~/ numLabelsThatFit);
                                        if (value.toInt() % actualInterval ==
                                            0) {
                                          DateTime date = dates[value.toInt()];
                                          String formattedDate =
                                              DateFormat('dd/MM/yy')
                                                  .format(date);
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: Text(formattedDate,
                                                style: const TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 13)),
                                          );
                                        }
                                        return const Text('');
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: false,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        if (value == minY) {
                                          return const Text('');
                                        }
                                        // Customizing the text for left titles
                                        return Text('€${value.toInt()}',
                                            style: const TextStyle(
                                                color: primaryColor,
                                                fontSize: 13));
                                      },
                                      reservedSize: 40, // Adjust as needed
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    isCurved: true,
                                    dotData: const FlDotData(show: false), // Hide the dots
                                    color: primaryColor,
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: primaryColor.withOpacity(0.3), // The fill color with some opacity
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
                if (widget.variation != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 25.0),
                    child: Center(
                      child: CupertinoSlidingSegmentedControl<TimeWindow>(
                        backgroundColor: Colors.transparent,
                        thumbColor: primaryColor,
                        children: {
                          TimeWindow.oneWeek: Text(
                              getString('walletBalanceGraphOneWeekText'),
                              style: TextStyle(
                                  color: timeWindow == TimeWindow.oneWeek
                                      ? Colors.white
                                          : isDarkMode
                                              ? lightTextColor
                                              : textColor)),
                          TimeWindow.oneMonth: Text(
                              getString('walletBalanceGraphOneMonthText'),
                              style: TextStyle(
                                  color: timeWindow == TimeWindow.oneMonth
                                      ? Colors.white
                                          : isDarkMode
                                              ? lightTextColor
                                              : textColor)),
                          TimeWindow.threeMonths: Text(
                              getString('walletBalanceGraphThreeMonthsText'),
                              style: TextStyle(
                                  color: timeWindow == TimeWindow.threeMonths
                                      ? Colors.white
                                      : isDarkMode
                                          ? lightTextColor
                                          : textColor)),
                          TimeWindow.oneYear: Text(
                              getString('walletBalanceGraphOneYearText'),
                              style: TextStyle(
                                  color: timeWindow == TimeWindow.oneYear
                                      ? Colors.white
                                          : isDarkMode
                                              ? lightTextColor
                                              : textColor)),
                          TimeWindow.tenYears: Text(
                              getString('walletBalanceGraphTenYearsText'),
                              style: TextStyle(
                                  color: timeWindow == TimeWindow.tenYears
                                      ? Colors.white
                                          : isDarkMode
                                              ? lightTextColor
                                              : textColor)),
                        },
                        groupValue: timeWindow,
                        onValueChanged: (TimeWindow? value) {
                          setState(() {
                            timeWindow = value!;
                          });
                        },
                      ),
                    ),
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
    return dates.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), data[entry.value]!)).toList();
  }
}
