import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePageBalanceComponent extends StatelessWidget {
  final double? balance;
  final double? variation;

  const HomePageBalanceComponent(
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
                        getString('homeBalanceText'),
                        style: TextStyle(
                            color: isDarkMode ? lightTextColor : textColor,
                            fontSize: 22),
                      ),
                      Skeletonizer(
                          enabled: variation == null,
                          child: Text(
                            "${(variation != null && !variation!.isNaN) ? variation!.toStringAsFixed(2) : '0'}%",
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
