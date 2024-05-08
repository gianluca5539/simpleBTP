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
  var finalValue = (value - buyPrice) * value / buyPrice;
  // check how many years are left
  DateTime expirationDate = DateTime.now();
  int cedolaPayments =
      -1; // -1 because now isn't a cedola payment like with expiration
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

void openMyBTPDetailModal(
    BuildContext context,
    isDarkMode,
    BTP btp,
    double buyPrice,
    DateTime buyDate,
    String? key,
    Function? deleteBTPFromWallet) {
  // Assume each label is about 60 pixels wide, change this based on your font size and style
  double labelWidth = 80;
  // Get the width of the chart
  double chartWidth = MediaQuery.of(context).size.width *
      0.9; // Since you're using 0.9 of screen width
  // Calculate the number of labels that could fit
  int numLabelsThatFit = chartWidth ~/ labelWidth;
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
            height: MediaQuery.of(context).size.height * 0.92,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 80,
                          height: 5,
                          decoration: BoxDecoration(
                            color:
                                isDarkMode ? darkModeColor : Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        btp.name.toUpperCase(),
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode ? primaryColorLight : primaryColor),
                      ),
                    ),
                    FutureBuilder<Map<DateTime, double>?>(
                      future: getCachedGraphData(btp.isin, timeWindow),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
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
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
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
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
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
                                            DateTime date =
                                                dates[value.toInt()];
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
                                      dotData: const FlDotData(
                                          show: false), // Hide the dots
                                      color: primaryColor,
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: primaryColor.withOpacity(
                                            0.3), // The fill color with some opacity
                                      ),
                                      spots: getSpots(snapshot.data!),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Center(
                        child: CupertinoSlidingSegmentedControl<TimeWindow>(
                          backgroundColor: Colors.transparent,
                          thumbColor: primaryColor,
                          children: {
                            TimeWindow.oneWeek:
                                Text(getString('walletBalanceGraphOneWeekText'),
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
                            TimeWindow.oneYear:
                                Text(getString('walletBalanceGraphOneYearText'),
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
                            setModalState(() {
                              timeWindow = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      getString('ExplorePageBTPInformationTitle'),
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? lightTextColor : textColor),
                    ),
                    const SizedBox(height: 10),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getString(
                                          'ExplorePageBTPInformationPrice'),
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? lightTextColor
                                              : textColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      btp.value.toString(),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getString(
                                          'WalletPageBTPInformationBuyPrice'),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getString(
                                          'ExplorePageBTPInformationExpirationDate'),
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? lightTextColor
                                              : textColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${btp.expirationDate.day}/${btp.expirationDate.month}/${btp.expirationDate.year}',
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getString(
                                          'WalletPageBTPInformationBuyDate'),
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? lightTextColor
                                              : textColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${buyDate.day}/${buyDate.month}/${buyDate.year}',
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getString(
                                          'ExplorePageBTPInformationISIN'),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getString(
                                          'WalletPageBTPInformationProfitability'),
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? lightTextColor
                                              : textColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${getMyBTPProfitabilityAtExpiration(
                                        buyPrice,
                                        btp.cedola,
                                        btp.expirationDate,
                                        buyDate,
                                      ).toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            getMyBTPProfitabilityAtExpiration(
                                                        buyPrice,
                                                        btp.cedola,
                                                        btp.expirationDate,
                                                        buyDate) <
                                                    0
                                                ? Colors.red
                                                : Colors.green,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getString(
                                          'WalletPageBTPInformationProfitabilityNow'),
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? lightTextColor
                                              : textColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${getMyBTPProfitabilityNow(
                                        btp.value,
                                        buyPrice,
                                        btp.cedola,
                                        buyDate,
                                      ).toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: getMyBTPProfitabilityNow(
                                                    btp.value,
                                                    buyPrice,
                                                    btp.cedola,
                                                    buyDate) <
                                                0
                                            ? Colors.red
                                            : Colors.green,
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
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          if (deleteBTPFromWallet != null) {
                            deleteBTPFromWallet(key, context, isDarkMode);
                          } else {
                            // show a dialog that the user can't delete this BTP
                            showCupertinoDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoTheme(
                                    data: CupertinoThemeData(
                                      brightness: isDarkMode
                                          ? Brightness.dark
                                          : Brightness.light,
                                    ),
                                    child: CupertinoAlertDialog(
                                      title: Text(getString(
                                          'MyBTPInformationDeleteError')),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: Text(
                                            getString(
                                                'ExplorePageBTPInformationDeleteErrorButton'),
                                            style: const TextStyle(
                                                color: primaryColor,
                                                fontSize: 16),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          }
                        },
                        child: Text(
                          getString('ExplorePageBTPInformationDeleteButton'),
                          style: TextStyle(
                              fontSize: 16,
                              color: deleteBTPFromWallet != null
                                  ? Colors.red[700]
                                  : Colors.grey),
                        ),
                      ),
                    ),
                  ]),
            ),
          );
        });
      });
}
