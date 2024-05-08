import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpinvestmentcomponent.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpsearch.dart';
import 'package:simpleBTP/WalletPage/walletpageinvestmentcomponent.dart';
import 'package:simpleBTP/WalletPage/walletpagebalancecomponent.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';
import 'package:simpleBTP/db/db.dart';
import 'package:simpleBTP/db/hivemodels.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String search = '';
  Map<String, dynamic> filters = defaultAddBTPFilters;
  Map<String, dynamic> ordering = defaultAddBTPOrdering;

  DateTime? selectedDate;
  double? price;
  int? investment;
  BTP? btp;

  TimeWindow timeWindow = TimeWindow.oneWeek;

  // Cache to store graph data
  Map<String, Map<TimeWindow, Map<DateTime, double>>> graphDataCache = {};

  String get purchaseDate {
    if (selectedDate == null) {
      return getString('addBTPPageSelectDateButton');
    }
    return "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
  }

  void _addBTPToWallet() {
    if (selectedDate == null || price == null || investment == null) {
      return;
    }
    addBTPToWallet(btp!.isin, selectedDate!, price!, investment!);
    setState(() {
      selectedDate = null;
      price = null;
      investment = null;
      btp = null;
    });
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  double _getBTPProfitabilityAtExpiration(double buyPrice, double cedola,
      DateTime expirationDate, DateTime buyDate) {
    var finalValue = (100 - buyPrice) * 100 / buyPrice;
    // check how many years are left
    int yearsLeft = expirationDate.year - buyDate.year;
    int cedolaPayments = yearsLeft * 2;
    if (expirationDate.month < buyDate.month ||
        (expirationDate.month == buyDate.month &&
            expirationDate.day < buyDate.day)) {
      cedolaPayments -= 1;
    }
    double totalCedola = cedolaPayments * cedola;
    double totalProfit = totalCedola + finalValue;
    return totalProfit;
  }

  double _getBTPProfitabilityNow(
      double value, double buyPrice, double cedola, DateTime buyDate) {
    var finalValue = (value - buyPrice) * value / buyPrice;
    // check how many years are left
    DateTime expirationDate = DateTime.now();
    int yearsLeft = expirationDate.year - buyDate.year;
    int cedolaPayments = yearsLeft * 2;
    if (expirationDate.month < buyDate.month ||
        (expirationDate.month == buyDate.month &&
            expirationDate.day < buyDate.day)) {
      cedolaPayments -= 1;
    }
    double totalCedola = cedolaPayments * cedola;
    double totalProfit = totalCedola + finalValue;
    return totalProfit;
  }

  Future<Map<DateTime, double>?> getCachedGraphData(String isin, TimeWindow timeWindow) async {
    if (graphDataCache.containsKey(isin) && graphDataCache[isin]!.containsKey(timeWindow)) {
      print('Cached data found for $isin');
      return graphDataCache[isin]?[timeWindow]!;
    } else {
      print('No cached data found for $isin');
      return createSingleBtpValueGraph(isin, timeWindow).then((value) {
        graphDataCache.putIfAbsent(isin, () => {})[timeWindow] = value;
        print('Cached data for $isin');
        return value;
      });
    }
  }

  List<FlSpot> _getSpots(Map<DateTime, double> data) {
    final dates = data.keys.toList()..sort(); // Ensure the dates are sorted
    return dates.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), data[entry.value]!)).toList();
  }

  void deleteBTPFromWallet(String key, BuildContext context) {
    // show a dialog to confirm the deletion
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: Text(
          getString('ExplorePageBTPInformationDeleteConfirmationMessage'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              removeBTPFromWallet(key);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              setState(() {});
            },
            child: Text(
              getString('ExplorePageBTPInformationDeleteConfirmationButton'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            getString('ExplorePageBTPInformationDeleteConfirmationCancelButton'),
            style: const TextStyle(color: primaryColor),
          ),
        ),
      ),
    );
  }

  void _openBTPDetailPage(BuildContext context, isDarkMode, BTP btp, buyPrice, buyDate, key) {
    // Assume each label is about 60 pixels wide, change this based on your font size and style
    double labelWidth = 80;
    // Get the width of the chart
    double chartWidth = MediaQuery.of(context).size.width * 0.9; // Since you're using 0.9 of screen width
    // Calculate the number of labels that could fit
    int numLabelsThatFit = chartWidth ~/ labelWidth;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.92,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      btp.name.toUpperCase(),
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDarkMode ? primaryColorLight : primaryColor),
                    ),
                  ),
                  FutureBuilder<Map<DateTime, double>?>(
                    future: getCachedGraphData(btp.isin, timeWindow),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
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
                      } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        // Determine minY and maxY for padding
                        final double minY = snapshot.data!.values.isNotEmpty
                            ? (snapshot.data!.values.reduce(min) * 0.95) // 5% padding at bottom
                            : 0;
                        final double maxY = snapshot.data!.values.isNotEmpty
                            ? (snapshot.data!.values.reduce(max) * 1.05) // 5% padding at top
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
                                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                      return touchedSpots.map((LineBarSpot touchedSpot) {
                                        final DateTime date = snapshot.data!.keys.toList()[touchedSpot.x.toInt()];
                                        final double value = touchedSpot.y;
                                        return LineTooltipItem(
                                          '€${value.toStringAsFixed(2).replaceAll(".", ",").replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}\n${DateFormat('dd/MM/yy').format(date)}',
                                          const TextStyle(color: lightTextColor),
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
                                    color: Colors.grey[200],
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
                                    sideTitles: SideTitles(showTitles: false), // No right titles
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false), // No top titles
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: false,
                                      interval: 1, // Start with an interval of 1
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        final dates = snapshot.data!.keys.toList()..sort();
                                        // Calculate the actual interval based on the data length and the number of labels that fit
                                        int actualInterval = max(1, dates.length ~/ numLabelsThatFit);
                                        if (value.toInt() % actualInterval == 0) {
                                          DateTime date = dates[value.toInt()];
                                          String formattedDate = DateFormat('dd/MM/yy').format(date);
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: Text(formattedDate, style: const TextStyle(color: primaryColor, fontSize: 13)),
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
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        if (value == minY) {
                                          return const Text('');
                                        }
                                        // Customizing the text for left titles
                                        return Text('€${value.toInt()}', style: const TextStyle(color: primaryColor, fontSize: 13));
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Center(
                      child: CupertinoSlidingSegmentedControl<TimeWindow>(
                        backgroundColor: Colors.transparent,
                        thumbColor: primaryColor,
                        children: {
                          TimeWindow.oneWeek: Text(getString('walletBalanceGraphOneWeekText'),
                              style: TextStyle(color: timeWindow == TimeWindow.oneWeek ? Colors.white : textColor)),
                          TimeWindow.oneMonth: Text(getString('walletBalanceGraphOneMonthText'),
                              style: TextStyle(color: timeWindow == TimeWindow.oneMonth ? Colors.white : textColor)),
                          TimeWindow.threeMonths: Text(getString('walletBalanceGraphThreeMonthsText'),
                              style: TextStyle(color: timeWindow == TimeWindow.threeMonths ? Colors.white : textColor)),
                          TimeWindow.oneYear: Text(getString('walletBalanceGraphOneYearText'),
                              style: TextStyle(color: timeWindow == TimeWindow.oneYear ? Colors.white : textColor)),
                          TimeWindow.tenYears: Text(getString('walletBalanceGraphTenYearsText'),
                              style: TextStyle(color: timeWindow == TimeWindow.tenYears ? Colors.white : textColor)),
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
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getString('ExplorePageBTPInformationPrice'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    btp.value.toString(),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey[200],
                                thickness: 1,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getString('WalletPageBTPInformationBuyPrice'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    buyPrice.toString(),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey[200],
                                thickness: 1,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                        getString(
                                            'ExplorePageBTPInformationExpirationDate'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                        '${btp.expirationDate.day}/${btp.expirationDate.month}/${btp.expirationDate.year}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey[200],
                                thickness: 1,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                        getString(
                                            'WalletPageBTPInformationBuyDate'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                        '${buyDate.day}/${buyDate.month}/${buyDate.year}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey[200],
                                thickness: 1,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                        getString(
                                            'ExplorePageBTPInformationISIN'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                        btp.isin,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Colors.grey[200],
                                thickness: 1,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                        getString(
                                            'WalletPageBTPInformationProfitability'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                        '${_getBTPProfitabilityAtExpiration(
                                          buyPrice,
                                          btp.cedola,
                                          btp.expirationDate,
                                          buyDate,
                                        ).toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              _getBTPProfitabilityAtExpiration(
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
                                    color: Colors.grey[200],
                                    thickness: 1,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        getString(
                                            'WalletPageBTPInformationProfitabilityNow'),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${_getBTPProfitabilityNow(
                                          btp.value,
                                          buyPrice,
                                          btp.cedola,
                                          buyDate,
                                        ).toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _getBTPProfitabilityNow(
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
                        deleteBTPFromWallet(key, context);
                      },
                      child: Text(
                        getString('ExplorePageBTPInformationDeleteButton'),
                        style: TextStyle(fontSize: 16, color: Colors.red[700]),
                      ),
                    ),
                  ),
                ]),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    void openAddBTPModal2() {
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
              void _showDatePickerDialog(Widget child, bool isDarkMode) {
                showCupertinoModalPopup<void>(
                  context: context,
                  builder: (BuildContext context) => Container(
                    height: 216,
                    padding: const EdgeInsets.only(top: 6.0),
                    // The Bottom margin is provided to align the popup above the system
                    // navigation bar.
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    // Provide a background color for the popup.
                    color: isDarkMode ? darkModeColor : CupertinoColors.white,
                    // Use a SafeArea widget to avoid system overlaps.
                    child: SafeArea(
                      top: false,
                      child: child,
                    ),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? offBlackColor : offWhiteColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.92,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('‹ ',
                                        style: TextStyle(fontFamily: 'Arial', color: isDarkMode ? primaryColorLight : primaryColor, fontSize: 30)),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(getString('addBTPSecondPageBackButton'),
                                          style: TextStyle(color: isDarkMode ? primaryColorLight : primaryColor, fontSize: 18)),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              btp!.name.toUpperCase(),
                              style: TextStyle(fontSize: 24, color: isDarkMode ? lightTextColor : textColor),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(getString('addBTPPageDateSectionTitle'),
                              style: TextStyle(fontSize: 20, color: isDarkMode ? lightTextColor : textColor)),
                          const SizedBox(height: 15),
                          Center(
                              child: ElevatedButton(
                            onPressed: () => _showDatePickerDialog(
                                CupertinoTheme(
                                  data: CupertinoThemeData(
                                    brightness: isDarkMode ? Brightness.dark : Brightness.light,
                                  ),
                                  child: CupertinoDatePicker(
                                    backgroundColor: isDarkMode ? darkModeColor : Colors.white,
                                    initialDateTime: DateTime.now(),
                                    mode: CupertinoDatePickerMode.date,
                                    use24hFormat: true,
                                    onDateTimeChanged: (DateTime newDate) {
                                      setModalState(() {
                                        selectedDate = newDate;
                                      });
                                    },
                                    maximumYear: DateTime.now().year,
                                    minimumYear: 1950,
                                  ),
                                ),
                                isDarkMode),
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(const Size(double.infinity, 45)),
                              elevation: MaterialStateProperty.all(1),
                              surfaceTintColor: MaterialStateProperty.all(isDarkMode ? darkModeColor : Colors.white),
                              backgroundColor: MaterialStateProperty.all(isDarkMode ? darkModeColor : Colors.white),
                              foregroundColor: isDarkMode ? MaterialStateProperty.all(lightTextColor) : MaterialStateProperty.all(textColor),
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              overlayColor: MaterialStateProperty.all(primaryColor.withOpacity(0.3)),
                              shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                            ),
                            child: Text(
                              purchaseDate,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? lightTextColor : textColor),
                            ),
                          )),
                          const SizedBox(height: 30),
                          Text(getString('addBTPPagePriceSectionTitle'),
                              style: TextStyle(fontSize: 20, color: isDarkMode ? lightTextColor : textColor)),
                          const SizedBox(height: 10),
                          // add textfield
                          Material(
                            elevation: 1,
                            borderRadius: BorderRadius.circular(10),
                            child: TextField(
                              onChanged: (value) => price = double.tryParse(value.replaceAll(',', '.')),
                              keyboardType: TextInputType.number,
                              // allow only numbers and one comma or dot with two decimal places (max)
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}')),
                              ],
                              style: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode
                                      ? lightTextColor
                                      : isDarkMode
                                          ? lightTextColor
                                          : textColor),
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDarkMode ? darkModeColor : Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode ? darkModeColor : Colors.white),
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode ? darkModeColor : Colors.white),
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: getString('addBTPPagePriceSectionPlaceholder'),
                                hintStyle: TextStyle(
                                    fontSize: 18,
                                    color: isDarkMode
                                        ? lightTextColor
                                        : isDarkMode
                                            ? lightTextColor
                                            : textColor),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(getString('addBTPPageInvestmentSectionTitle'),
                              style: TextStyle(fontSize: 20, color: isDarkMode ? lightTextColor : textColor)),
                          const SizedBox(height: 10),
                          // add textfield
                          Material(
                            elevation: 1,
                            borderRadius: BorderRadius.circular(10),
                            child: TextField(
                              onChanged: (value) => investment = int.tryParse(value),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                              ],
                              style: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode
                                      ? lightTextColor
                                      : isDarkMode
                                          ? lightTextColor
                                          : textColor),
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDarkMode ? darkModeColor : Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode ? darkModeColor : Colors.white),
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: isDarkMode ? darkModeColor : Colors.white),
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                ),
                                hintText: getString('addBTPPageInvestmentSectionPlaceholder'),
                                hintStyle: TextStyle(
                                    fontSize: 18,
                                    color: isDarkMode
                                        ? lightTextColor
                                        : isDarkMode
                                            ? lightTextColor
                                            : textColor),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: () => _addBTPToWallet(),
                            style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(const Size(double.infinity, 45)),
                              elevation: MaterialStateProperty.all(1),
                              backgroundColor: MaterialStateProperty.all(isDarkMode ? primaryColorLight : primaryColor),
                              foregroundColor: MaterialStateProperty.all(Colors.white),
                              padding: MaterialStateProperty.all(EdgeInsets.zero),
                              overlayColor: MaterialStateProperty.all(primaryColor.withOpacity(0.3)),
                              shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                            ),
                            child: Text(
                              getString('addBTPPageAddButton'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: lightTextColor),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          });
    }

    void openAddBTPModal() {
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
              void searchWithFilters(String search, Map<String, dynamic> filters, Map<String, dynamic> ordering) {
                // update the state with the new search and filters
                setModalState(() {
                  this.search = search;
                  this.filters = filters;
                  this.ordering = ordering;
                });
              }

              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? offBlackColor : offWhiteColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.92,
                child: Column(
                  children: [
                    Padding(
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
                    AddBTPSearch(searchWithFilters),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.74,
                      child: SingleChildScrollView(
                        child: FutureBuilder<List<BTP>>(
                          future: getAddBTPPageBTPs(search, filters, ordering),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Column(
                                  children: List.generate(
                                      5,
                                      (index) => const AddBTPInvestmentComponent(
                                          investmentName: null, investmentDetail: null, cedola: null, investmentValue: null, variation: null)));
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}'); // Handle errors
                            } else if (snapshot.hasData) {
                              final assets = snapshot.data!;
                              final investmentList = assets.map((asset) {
                                final name = processString(asset.name);
                                // final percentage = name[0];
                                final withBtp = name[1];
                                final btpLess = name[2];
                                final double value = asset.value;
                                final double cedola = asset.cedola;
                                var variation = (value - 100);
                                // make it have 3 decimal places
                                variation = double.parse(variation.toStringAsFixed(3));

                                return TextButton(
                                    onPressed: () {
                                      setState(() {
                                        btp = asset;
                                      });
                                      openAddBTPModal2();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                                      overlayColor: MaterialStateProperty.all(primaryColor.withOpacity(0.3)),
                                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                                    ),
                                    child: AddBTPInvestmentComponent(
                                      investmentName: btpLess ?? "Unknown",
                                      investmentDetail: "$withBtp",
                                      cedola: "${cedola * 2}%",
                                      investmentValue: value,
                                      variation: variation,
                                    ));
                              }).toList();
                              return Column(children: investmentList);
                            } else {
                              return const Text('No data'); // Handle the case of no data
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          });
    }

    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : offWhiteColor,
      appBar: AppTopBar(getString('appTopBarWallet'), {
        'icon': Icons.add,
        'onPressed': () {
          openAddBTPModal();
        }
      }),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: FutureBuilder<Map<String, double>>(
                  future: getWalletStats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const WalletPageBalanceComponent(balance: null, variation: null);
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // Handle errors
                    } else if (snapshot.hasData) {
                      double balance = snapshot.data!['balance']!;
                      double variation = snapshot.data!['variation']!;
                      // limit variation to 3 decimal places
                      variation = double.parse(variation.toStringAsFixed(2));
                      return WalletPageBalanceComponent(balance: balance, variation: variation);
                    }
                    return const Text('No data'); // Handle the case of no data
                  }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                getString('walletMyAssets'),
                style: TextStyle(fontSize: 24, color: isDarkMode ? lightTextColor : textColor),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getWalletPageMyBTPs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: List.generate(
                      2,
                      (index) => const WalletPageInvestmentComponent(
                        investmentName: null,
                        investmentDetail: null,
                        cedola: null,
                        investmentValue: null,
                        variation: null,
                        expirationDate: null,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Handle errors
                } else if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                      child: Text(
                        getString('walletPageNoBTPsYet'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDarkMode ? lightTextColor : textColor),
                      ),
                    );
                  }
                  final assets = snapshot.data!;
                  final investmentList = assets.map((asset) {
                    final name = processString(asset['btp'].name);
                    // final percentage = name[0];
                    final withBtp = name[1];
                    final btpLess = name[2];
                    final double value = asset['value'];
                    final double cedola = asset['btp'].cedola;
                    double variation = asset['variation'];
                    // fix variation to have 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(3));
                    final date = asset['btp'].expirationDate;

                    return TextButton(
                        onPressed: () => _openBTPDetailPage(context, isDarkMode, asset['btp'], asset['buyPrice'], asset['buyDate'], asset['key']),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          overlayColor: MaterialStateProperty.all(primaryColor.withOpacity(0.3)),
                          shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                        ),
                        child: WalletPageInvestmentComponent(
                          investmentName: btpLess ?? "Unknown",
                          investmentDetail: "$withBtp",
                          cedola: "$cedola%",
                          investmentValue: value,
                          variation: variation,
                          expirationDate: date,
                        ));
                  }).toList();
                  return Column(children: investmentList);
                } else {
                  return const Text('No data'); // Handle the case of no data
                }
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Footer('wallet'),
    );
  }
}
