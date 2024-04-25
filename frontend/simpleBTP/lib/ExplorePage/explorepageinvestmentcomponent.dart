import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ExplorePageInvestmentComponent extends StatelessWidget {
  final String? investmentName;
  final String? investmentDetail;
  final String? cedola;
  final double? investmentValue;
  final double? variation;

  const ExplorePageInvestmentComponent({
    super.key,
    required this.investmentName,
    required this.investmentDetail,
    required this.cedola,
    required this.investmentValue,
    required this.variation,
  });

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
                      investmentDetail?.toUpperCase() ?? '----------',
                      style: TextStyle(
                          color: isDarkMode ? lightTextColor : textColor,
                          fontSize: 16),
                    ),
                    Text(
                      cedola ?? '----',
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
                    "€${investmentValue?.toStringAsFixed(2).replaceAll(".", ",")}",
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
