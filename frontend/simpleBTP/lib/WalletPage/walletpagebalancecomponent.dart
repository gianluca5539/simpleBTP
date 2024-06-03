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

    return Center(
      child: Container(
        color: Colors.white,
        width: 0.9 * MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
          child: Column(
            // align text to the left
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 17.0, right: 17.0, top: 5.0),
                child: Skeletonizer(
                    enabled: widget.balance == null,
                    child: Text(
                      "€${widget.balance == null ? '----' : ''}${widget.balance?.toStringAsFixed(2).replaceAll(".", ",").replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}",
                      style: TextStyle(
                          color: isDarkMode ? lightTextColor : textColor,
                          fontSize: 34,
                          fontWeight: FontWeight.bold),
                    )),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.only(left: 17.0),
                child: Skeletonizer(
                  enabled: widget.variation == null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: (widget.variation ?? 0) > 0
                          ? positiveColor
                          : negativeColor,
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: Text(
                      "${(widget.variation ?? 0) > 0 ? "▲" : "▼"} ${widget.variation?.toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: (widget.variation ?? 0) > 0
                            ? Colors.green
                            : Colors.red,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
