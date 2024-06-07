import 'dart:core';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
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
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    Color positiveColor = Colors.green.shade100; // Lighter green for positive variation
    Color negativeColor = Colors.red.shade100; // Lighter red for negative variation

    return Center(
      child: SizedBox(
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
                      "${(widget.variation ?? 0) > 0 ? "▲" : "▼"} ${(widget.variation == null ? 0 : widget.variation!.isNaN ? 0 : widget.variation)!.toStringAsFixed(2)}%",
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
}
