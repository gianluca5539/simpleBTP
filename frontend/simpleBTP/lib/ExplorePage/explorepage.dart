import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/ExplorePage/explorepageinvestmentcomponent.dart';
import 'package:simpleBTP/ExplorePage/explorepagesearchandfiltercomponent.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/appTopBar/apptopbar.dart';
import 'package:simpleBTP/components/BTPDetail/btp_detail.dart';
import 'package:simpleBTP/components/Footer/footer.dart';
import 'package:simpleBTP/db/db.dart';
import 'package:simpleBTP/db/hivemodels.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String search = '';

  Map<String, dynamic> filters = defaultExploreFilters;

  Map<String, dynamic> ordering = defaultExploreOrdering;

  TimeWindow timeWindow = TimeWindow.oneWeek;

  DateTime selectedDate = DateTime.now();
  double price = 0.0;
  int investment = 0;
  BTP? btp;
  bool showErrorInvestmentTooLow = true;

  String getTotalInvestment() {
    return (price * investment).toStringAsFixed(2);
  }

  String get purchaseDate {
    if (selectedDate == null) {
      selectedDate = DateTime.now();
    }
    return "${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}";
  }

  void searchWithFilters(String search, Map<String, dynamic> filters,
      Map<String, dynamic> ordering) {
    // update the state with the new search and filters
    setState(() {
      this.search = search;
      this.filters = filters;
      this.ordering = ordering;
    });
  }

  void _addBTPToWallet(context) {
    // show cupertino sheet to choose payment method
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(getString('addBTPPagePaymentMethodTitle'),
                style: const TextStyle(fontSize: 18)),
            content: Text(
              getString('addBTPPagePaymentMethodMessage'),
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  addBTPToWallet(btp!.isin, selectedDate ?? DateTime.now(),
                      price, investment);
                  Navigator.pop(context);
                  setState(() {
                    selectedDate = DateTime.now();
                    price = 0.0;
                    investment = 0;
                    btp = null;
                    showErrorInvestmentTooLow = true;
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(getString('addBTPPagePaymentMethodApplePay')),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  addBTPToWallet(btp!.isin, selectedDate ?? DateTime.now(),
                      price, investment);
                  Navigator.pop(context);
                  setState(() {
                    selectedDate = DateTime.now();
                    price = 0.0;
                    investment = 0;
                    btp = null;
                    showErrorInvestmentTooLow = true;
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(getString('addBTPPagePaymentMethodDebit')),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  addBTPToWallet(btp!.isin, selectedDate ?? DateTime.now(),
                      price, investment);
                  Navigator.pop(context);
                  setState(() {
                    selectedDate = DateTime.now();
                    price = 0.0;
                    investment = 0;
                    btp = null;
                    showErrorInvestmentTooLow = true;
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(getString('addBTPPagePaymentMethodPaypal')),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  getString('addBTPPagePaymentMethodCancel'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }

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
        color: isDarkMode ? darkModeColor : Colors.white,
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  void openAddBTPModal(context, isDarkMode, btpName) {
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
                                      style: TextStyle(
                                          fontFamily: 'Arial',
                                          color: isDarkMode
                                              ? primaryColorLight
                                              : primaryColor,
                                          fontSize: 30)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                        btpName ??
                                            getString(
                                                'addBTPSecondPageBackButton'),
                                        style: TextStyle(
                                            color: isDarkMode
                                                ? primaryColorLight
                                                : primaryColor,
                                            fontSize: 18)),
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
                            btp?.name.toUpperCase() ?? '',
                            style: TextStyle(
                                fontSize: 24,
                                color: isDarkMode ? lightTextColor : textColor),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(getString('addBTPPageDateSectionTitle'),
                            style: const TextStyle(
                                fontSize: 20, color: Colors.grey)),
                        const SizedBox(height: 15),
                        Center(
                            child: ElevatedButton(
                          onPressed: () => _showDatePickerDialog(
                              CupertinoTheme(
                                data: CupertinoThemeData(
                                  brightness: isDarkMode
                                      ? Brightness.dark
                                      : Brightness.light,
                                ),
                                child: CupertinoDatePicker(
                                  backgroundColor:
                                      isDarkMode ? darkModeColor : Colors.white,
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
                            minimumSize: MaterialStateProperty.all(
                                const Size(double.infinity, 45)),
                            elevation: MaterialStateProperty.all(1),
                            surfaceTintColor: MaterialStateProperty.all(
                                isDarkMode ? darkModeColor : Colors.white),
                            backgroundColor: MaterialStateProperty.all(
                                isDarkMode ? darkModeColor : Colors.white),
                            foregroundColor: isDarkMode
                                ? MaterialStateProperty.all(lightTextColor)
                                : MaterialStateProperty.all(textColor),
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            overlayColor: MaterialStateProperty.all(
                                primaryColor.withOpacity(0.3)),
                            shape: MaterialStateProperty.all(
                                const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                          ),
                          child: Text(
                            purchaseDate,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? lightTextColor : textColor),
                          ),
                        )),
                        const SizedBox(height: 30),
                        Text(getString('addBTPPagePriceSectionTitle'),
                            style: const TextStyle(
                                fontSize: 20, color: Colors.grey)),
                        const SizedBox(height: 10),
                        // add textfield
                        Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(10),
                          child: TextFormField(
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            initialValue: price.toString(),
                            onChanged: (value) {
                              setModalState(() {
                                price = double.tryParse(
                                        value.replaceAll(',', '.')) ??
                                    0.0;
                                if (price * investment < 1000) {
                                  showErrorInvestmentTooLow = true;
                                } else {
                                  showErrorInvestmentTooLow = false;
                                }
                              });
                            },
                            keyboardType: TextInputType.number,
                            // allow only numbers and one comma or dot with two decimal places (max)
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+[,.]?\d{0,2}')),
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
                              fillColor:
                                  isDarkMode ? darkModeColor : Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? darkModeColor
                                        : Colors.white),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? darkModeColor
                                        : Colors.white),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              hintText: getString(
                                  'addBTPPagePriceSectionPlaceholder'),
                              hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode
                                      ? lightTextColor
                                      : isDarkMode
                                          ? lightTextColor
                                          : textColor),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(getString('addBTPPageInvestmentSectionTitle'),
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                    isDarkMode ? lightTextColor : textColor)),
                        const SizedBox(height: 10),
                        // add textfield
                        Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(10),
                          child: TextField(
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            onChanged: (value) {
                              setModalState(() {
                                investment = int.tryParse(value) ?? 0;
                                if (price * investment < 1000) {
                                  showErrorInvestmentTooLow = true;
                                } else {
                                  showErrorInvestmentTooLow = false;
                                }
                              });
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+')),
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
                              fillColor:
                                  isDarkMode ? darkModeColor : Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? darkModeColor
                                        : Colors.white),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: isDarkMode
                                        ? darkModeColor
                                        : Colors.white),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              hintText: getString(
                                  'addBTPPageInvestmentSectionPlaceholder'),
                              hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: isDarkMode
                                      ? lightTextColor
                                      : isDarkMode
                                          ? lightTextColor
                                          : textColor),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(getString('total'),
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                    isDarkMode ? lightTextColor : textColor)),
                        const SizedBox(height: 10),
                        Text(getTotalInvestment(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 26,
                                color:
                                    isDarkMode ? lightTextColor : textColor)),
                        const SizedBox(height: 10),
                      ],
                    ),
                    Column(
                      children: [
                        if (showErrorInvestmentTooLow)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              getString('addBTPPageInvestmentTooLowError'),
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            if (price * investment >= 1000) {
                              _addBTPToWallet(context);
                            }
                          },
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                                const Size(double.infinity, 45)),
                            elevation: MaterialStateProperty.all(1),
                            backgroundColor: MaterialStateProperty.all(
                                investment * price < 1000
                                    ? Colors.grey
                                    : isDarkMode
                                        ? primaryColorLight
                                        : primaryColor),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            padding: MaterialStateProperty.all(EdgeInsets.zero),
                            overlayColor: MaterialStateProperty.all(
                                primaryColor.withOpacity(0.3)),
                            shape: MaterialStateProperty.all(
                                const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                          ),
                          child: Text(
                            getString('addBTPPageAddButton'),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: lightTextColor),
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
        }).then((value) {
      setState(() {
        selectedDate = DateTime.now();
        price = 0.0;
        investment = 0;
        btp = null;
        showErrorInvestmentTooLow = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : offWhiteColor,
      appBar: appTopBar(getString('appTopBarExplore'), null),
      // add a body and a footer
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExplorePageSearchAndFilterComponent(searchWithFilters),
            FutureBuilder<List<BTP>>(
              future: getExplorePageBTPs(search, filters, ordering),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                      children: List.generate(
                          5,
                          (index) => const ExplorePageInvestmentComponent(
                              investmentName: null,
                              investmentDetail: null,
                              cedola: null,
                              investmentValue: null,
                              variation: null)));
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
                        onPressed: () =>
                            openBTPDetailModal(context, isDarkMode, asset, () {
                              setState(() {
                                btp = asset;
                                price = value;
                                openAddBTPModal(context, isDarkMode,
                                    asset.name.toUpperCase());
                              });
                            }),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                          overlayColor: MaterialStateProperty.all(
                              primaryColor.withOpacity(0.3)),
                          shape: MaterialStateProperty.all(
                              const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero)),
                        ),
                        child: ExplorePageInvestmentComponent(
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
          ],
        ),
      ),
      bottomNavigationBar: Footer('explore'),
    );
  }
}
