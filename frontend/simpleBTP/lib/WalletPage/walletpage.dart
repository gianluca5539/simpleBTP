import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
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

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    void openAddBTPModal2() {
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              void _showDatePickerDialog(Widget child) {
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
                    color:
                        CupertinoColors.systemBackground.resolveFrom(context),
                    // Use a SafeArea widget to avoid system overlaps.
                    child: SafeArea(
                      top: false,
                      child: child,
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.92,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('‹ ',
                                          style: TextStyle(
                                              fontFamily: 'Arial',
                                              color: isDarkMode
                                                  ? primaryColorLight
                                                  : primaryColor,
                                              fontSize: 30)),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6.0),
                                        child: Text(
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
                                btp!.name.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 24,
                                    color: isDarkMode
                                        ? lightTextColor
                                        : textColor),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(getString('addBTPPageDateSectionTitle'),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: isDarkMode
                                        ? lightTextColor
                                        : textColor)),
                            const SizedBox(height: 15),
                            Center(
                                child: ElevatedButton(
                              onPressed: () => _showDatePickerDialog(
                                CupertinoDatePicker(
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
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero),
                                overlayColor: MaterialStateProperty.all(
                                    primaryColor.withOpacity(0.3)),
                                shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)))),
                              ),
                              child: Text(
                                purchaseDate,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? lightTextColor
                                        : textColor),
                              ),
                            )),
                            const SizedBox(height: 30),
                            Text(getString('addBTPPagePriceSectionTitle'),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: isDarkMode
                                        ? lightTextColor
                                        : textColor)),
                            const SizedBox(height: 10),
                            // add textfield
                            Material(
                              elevation: 1,
                              borderRadius: BorderRadius.circular(10),
                              child: TextField(
                                onChanged: (value) =>
                                    price = double.tryParse(value),
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
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      isDarkMode ? darkModeColor : Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: isDarkMode
                                            ? darkModeColor
                                            : Colors.white),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: isDarkMode
                                            ? darkModeColor
                                            : Colors.white),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(getString('addBTPPageInvestmentSectionTitle'),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: isDarkMode
                                        ? lightTextColor
                                        : textColor)),
                            const SizedBox(height: 10),
                            // add textfield
                            Material(
                              elevation: 1,
                              borderRadius: BorderRadius.circular(10),
                              child: TextField(
                                onChanged: (value) =>
                                    investment = int.tryParse(value),
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
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      isDarkMode ? darkModeColor : Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: isDarkMode
                                            ? darkModeColor
                                            : Colors.white),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: isDarkMode
                                            ? darkModeColor
                                            : Colors.white),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
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
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
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
                                minimumSize: MaterialStateProperty.all(
                                    const Size(double.infinity, 45)),
                                elevation: MaterialStateProperty.all(1),
                                backgroundColor: MaterialStateProperty.all(
                                    isDarkMode
                                        ? primaryColorLight
                                        : primaryColor),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                padding:
                                    MaterialStateProperty.all(EdgeInsets.zero),
                                overlayColor: MaterialStateProperty.all(
                                    primaryColor.withOpacity(0.3)),
                                shape: MaterialStateProperty.all(
                                    const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)))),
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
                    )),
              );
            });
          });
    }

    void openAddBTPModal() {
      showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              void searchWithFilters(String search,
                  Map<String, dynamic> filters, Map<String, dynamic> ordering) {
                // update the state with the new search and filters
                setModalState(() {
                  this.search = search;
                  this.filters = filters;
                  this.ordering = ordering;
                });
              }

              return SizedBox(
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Column(
                                  children: List.generate(
                                      5,
                                      (index) =>
                                          const AddBTPInvestmentComponent(
                                              investmentName: null,
                                              investmentDetail: null,
                                              cedola: null,
                                              investmentValue: null,
                                              variation: null)));
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Error: ${snapshot.error}'); // Handle errors
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
                                variation =
                                    double.parse(variation.toStringAsFixed(3));

                                return TextButton(
                                    onPressed: () {
                                      setState(() {
                                        btp = asset;
                                      });
                                      openAddBTPModal2();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.transparent),
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.zero),
                                      overlayColor: MaterialStateProperty.all(
                                          primaryColor.withOpacity(0.3)),
                                      shape: MaterialStateProperty.all(
                                          const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero)),
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
                              return const Text(
                                  'No data'); // Handle the case of no data
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
                      return const WalletPageBalanceComponent(
                          balance: null, variation: null);
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // Handle errors
                    } else if (snapshot.hasData) {
                      double balance = snapshot.data!['balance']!;
                      double variation = snapshot.data!['variation']!;
                      // limit variation to 3 decimal places
                      variation = double.parse(variation.toStringAsFixed(2));
                      return WalletPageBalanceComponent(
                          balance: balance, variation: variation);
                    }
                    return const Text('No data'); // Handle the case of no data
                  }),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                getString('walletMyAssets'),
                style: TextStyle(
                    fontSize: 24,
                    color: isDarkMode ? lightTextColor : textColor),
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
                        buyDate: null,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Handle errors
                } else if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10),
                      child: Text(
                        getString('walletPageNoBTPsYet'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isDarkMode ? lightTextColor : textColor),
                      ),
                    );
                  }
                  final assets = snapshot.data!;
                  final investmentList = assets.map((asset) {
                    final name = processString(asset['name'] ?? 'N/A');
                    // final percentage = name[0];
                    final withBtp = name[1];
                    final btpLess = name[2];
                    final double value = asset['value'];
                    final double cedola = asset['cedola'];
                    double variation = asset['variation'];
                    // fix variation to have 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(3));
                    final date = asset['buyDate'];

                    return WalletPageInvestmentComponent(
                      investmentName: btpLess ?? "Unknown",
                      investmentDetail: "$withBtp",
                      cedola: "$cedola%",
                      investmentValue: value,
                      variation: variation,
                      buyDate: date,
                    );
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
