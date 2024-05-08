import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePageBalanceComponent extends StatelessWidget {
  final double? balance;
  final double? variation;

  const HomePageBalanceComponent({super.key, required this.balance, required this.variation});

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    Color positiveColor = Colors.green.shade100; // Lighter green for positive variation
    Color negativeColor = Colors.red.shade100; // Lighter red for negative variation

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                getString('homeBalanceText'),
                style: TextStyle(
                  color: isDarkMode ? lightTextColor : Color.fromARGB(255, 144, 144, 144),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Skeletonizer(
                enabled: balance == null,
                child: Text(
                  "€${balance == null ? '----' : ''}${balance?.toStringAsFixed(2).replaceAll(".", ",").replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}",
                  style: TextStyle(
                    color: isDarkMode ? lightTextColor : textColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Skeletonizer(
                enabled: variation == null,
                child: Container(
                  decoration: BoxDecoration(
                    color: (variation ?? 0) > 0 ? positiveColor : negativeColor,
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: Text(
                    "${(variation ?? 0) > 0 ? "▲" : "▼"} ${variation?.toStringAsFixed(2)}%", 
                    style: TextStyle(
                      color: (variation ?? 0) > 0 ? Colors.green : Colors.red,
                      fontSize: 18,
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
