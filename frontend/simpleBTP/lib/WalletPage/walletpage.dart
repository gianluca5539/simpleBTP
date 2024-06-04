import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpinvestmentcomponent.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpsearch.dart';
import 'package:simpleBTP/WalletPage/walletpageinvestmentcomponent.dart';
import 'package:simpleBTP/WalletPage/walletpagebalancecomponent.dart';
import 'package:simpleBTP/WalletPage/walletpageoldinvestmentcomponent.dart';
import 'package:simpleBTP/SettingsPage/picklanguagepage.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/appTopBar/apptopbar.dart';
import 'package:simpleBTP/components/BTPDetail/my_btp_detail.dart';
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

  DateTime? selectedDate = DateTime.now();
  double price = 0.0;
  int investment = 0;
  BTP? btp;
  bool showErrorInvestmentTooLow = true;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    Box settings = Hive.box('settings');
    darkMode = settings.get('darkMode', defaultValue: false);
  }

  void toggleDarkMode(value) {
    setState(() {
      darkMode = value;
      Box settings = Hive.box('settings');
      settings.put('darkMode', value);
    });
  }

  void openPickLanguagePage(BuildContext context) {
    Navigator.push(
        context,
        (MaterialPageRoute(builder: (context) {
          return const PickLanguagePage();
        }))).then((value) => setState(() {}));
  }

  String get purchaseDate {
    selectedDate ??= DateTime.now();
    return "${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}";
  }

  void _addBTPToWallet() {
    // show cupertino sheet to choose payment method
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Text(getString('addBTPPagePaymentMethodTitle'), style: const TextStyle(fontSize: 18)),
            message: Text(
              getString('addBTPPagePaymentMethodMessage'),
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  addBTPToWallet(btp!.isin, selectedDate ?? DateTime.now(), price, investment);
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
              CupertinoActionSheetAction(
                onPressed: () {
                  addBTPToWallet(btp!.isin, selectedDate ?? DateTime.now(), price, investment);
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
              CupertinoActionSheetAction(
                onPressed: () {
                  addBTPToWallet(btp!.isin, selectedDate ?? DateTime.now(), price, investment);
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
              CupertinoActionSheetAction(
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

  getTotalInvestment() {
    return '€${(price * investment).toStringAsFixed(2)}';
  }

  void _deleteBTPFromWallet(String key, BuildContext context, bool isDarkMode) {
    // show a dialog to confirm the deletion
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoTheme(
              data: CupertinoThemeData(
                brightness: isDarkMode ? Brightness.dark : Brightness.light,
              ),
              child: CupertinoActionSheet(
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
            ));
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

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    void openAddBTPModal2() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            width: double.infinity, // Make the bottom sheet span full width
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Account Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Implement action for wallet backup
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Wallet Backup'),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  ElevatedButton(
                    onPressed: () {
                      // Implement action for wallet backup restore
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Wallet Backup Restore'),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  ElevatedButton(
                    onPressed: () {
                      // Implement action for wallet delete
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Wallet Delete'),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Personalization',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  SwitchListTile(
                    title: Text('Dark Mode'),
                    value: darkMode,
                    onChanged: toggleDarkMode,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      openPickLanguagePage(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Language'),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
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
                                        price = asset.value;
                                      });
                                      openAddBTPModal2();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                                      overlayColor: MaterialStateProperty.all(primaryColor.withOpacity(0.3)),
                                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                                    ),
                                    child: Column(children: [
                                      AddBTPInvestmentComponent(
                                        investmentName: btpLess ?? "Unknown",
                                        investmentDetail: "$withBtp",
                                        cedola: "${cedola * 2}%",
                                        investmentValue: value,
                                        variation: variation,
                                      ),
                                      Divider(
                                        height: 1,
                                        color: Colors.grey[200],
                                      )
                                    ]));
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
      appBar: appTopBar(getString('simpleBTP'), [
        {
          'icon': Icons.settings_outlined,
          'onPressed': () {
            openAddBTPModal2();
          }
        },
        {
          'icon': Icons.add,
          'onPressed': () {
            openAddBTPModal();
          }
        },
      ]),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                getString('walletBalanceText'),
                style: TextStyle(fontSize: 24, color: isDarkMode ? lightTextColor : titleColor),
              ),
            ),
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
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                getString('walletMyAssets'),
                style: TextStyle(fontSize: 24, color: isDarkMode ? lightTextColor : titleColor),
              ),
            ),
            const SizedBox(height: 15),
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
                    final double value = asset['btp'].value * asset['investment'];
                    final double cedola = asset['btp'].cedola;
                    double variation = (asset['btp'].value - asset['buyPrice']) / asset['buyPrice'] * 100;
                    // fix variation to have 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(2));
                    final date = asset['btp'].expirationDate;

                    return TextButton(
                        onPressed: () => openMyBTPDetailModal(
                              context,
                              isDarkMode,
                              asset['btp'],
                              asset['buyPrice'],
                              asset['buyDate'],
                              asset['key'],
                              _deleteBTPFromWallet,
                            ),
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
                  return Column(
                      children: investmentList
                          .map((e) => Column(
                                children: [
                                  e,
                                  Divider(
                                    height: 1,
                                    color: Colors.grey[200],
                                  )
                                ],
                              ))
                          .toList());
                } else {
                  return const Text('No data'); // Handle the case of no data
                }
              },
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                getString('walletMyPastAssets'),
                style: TextStyle(fontSize: 24, color: isDarkMode ? lightTextColor : titleColor),
              ),
            ),
            const SizedBox(height: 15),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getWalletPageMyOldBTPs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: List.generate(
                      2,
                      (index) => const WalletPageOldInvestmentComponent(
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
                        getString('walletPageNoPastBTPsYet'),
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
                    final double value = asset['btp'].value * asset['investment'];
                    final double cedola = asset['btp'].cedola;
                    double variation = (asset['btp'].value - asset['buyPrice']) / asset['buyPrice'] * 100;
                    // fix variation to have 3 decimal places
                    variation = double.parse(variation.toStringAsFixed(2));
                    final date = asset['btp'].expirationDate;

                    return TextButton(
                        onPressed: () => openMyBTPDetailModal(
                              context,
                              isDarkMode,
                              asset['btp'],
                              asset['buyPrice'],
                              asset['buyDate'],
                              asset['key'],
                              _deleteBTPFromWallet,
                            ),
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
                  return Column(
                      children: investmentList
                          .map((e) => Column(
                                children: [
                                  e,
                                  Divider(
                                    height: 1,
                                    color: Colors.grey[200],
                                  )
                                ],
                              ))
                          .toList());
                } else {
                  return const Text('No data'); // Handle the case of no data
                }
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
