import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpinvestmentcomponent.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpsearch.dart';
import 'package:simpleBTP/WalletPage/walletpageinvestmentcomponent.dart';
import 'package:simpleBTP/WalletPage/walletpagebalancecomponent.dart';
import 'package:simpleBTP/WalletPage/walletpageoldinvestmentcomponent.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/OldBTPDetail/my_old_btp_detail.dart';
import 'package:simpleBTP/components/appTopBar/apptopbar.dart';
import 'package:simpleBTP/components/BTPDetail/my_btp_detail.dart';
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

  int modalPageAdd = 0;

  @override
  void initState() {
    super.initState();
    Box settings = Hive.box('settings');
    darkMode = settings.get('darkMode', defaultValue: false);
  }

  void toggleDarkMode(value) {
    darkMode = value;
    Box settings = Hive.box('settings');
    settings.put('darkMode', value);
    setState(() {});
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
            title: Text(getString('addBTPPagePaymentMethodTitle'),
                style: const TextStyle(fontSize: 18)),
            message: Text(
              getString('addBTPPagePaymentMethodMessage'),
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              CupertinoActionSheetAction(
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
                },
                child: Text(getString('addBTPPagePaymentMethodApplePay')),
              ),
              CupertinoActionSheetAction(
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
                },
                child: Text(getString('addBTPPagePaymentMethodDebit')),
              ),
              CupertinoActionSheetAction(
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

  void _deleteBTPFromWallet(
      String key, BuildContext context, bool isDarkMode, amount) {
    // show a dialog to confirm the deletion
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          Box box = Hive.box('credentials');
          String iban =
              box.get('iban', defaultValue: 'IT00A0000000000000000000000');
          return CupertinoTheme(
            data: CupertinoThemeData(
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            child: CupertinoActionSheet(
              title: const Text(
                'Are you sure you want to sell this BTP?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              message: Text(
                'You will receive €$amount on your IBAN: \n $iban',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                    getString(
                        'ExplorePageBTPInformationDeleteConfirmationButton'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  getString(
                      'ExplorePageBTPInformationDeleteConfirmationCancelButton'),
                  style: const TextStyle(color: primaryColor),
                ),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    // void openAddBTPModal2() {
    //   showModalBottomSheet(
    //       isScrollControlled: true,
    //       context: context,
    //       builder: (context) {
    //         return StatefulBuilder(
    //             builder: (BuildContext context, StateSetter setModalState) {
    //           return
    //         });
    // })
    // }

    void openSettingsModal() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: isDarkMode ? darkModeColor : Colors.white,
              ),

              width: double.infinity, // Make the bottom sheet span full width
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          color: isDarkMode ? lightTextColor : textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Account Settings',
                      style: TextStyle(
                        color: isDarkMode ? lightTextColor : textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                        overlayColor: MaterialStateProperty.all(
                            primaryColor.withOpacity(0)),
                      ),
                      onPressed: () {
                        // Implement action for wallet backup
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              color: isDarkMode ? lightTextColor : textColor,
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                    ),
                    TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                        overlayColor: MaterialStateProperty.all(
                            primaryColor.withOpacity(0)),
                      ),
                      onPressed: () {
                        // Implement action for wallet backup restore
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Withdrawal address',
                            style: TextStyle(
                              color: isDarkMode ? lightTextColor : textColor,
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                    ),
                    TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                        overlayColor: MaterialStateProperty.all(
                            primaryColor.withOpacity(0)),
                      ),
                      onPressed: () {
                        // Implement action for wallet delete
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Notification options',
                            style: TextStyle(
                              color: isDarkMode ? lightTextColor : textColor,
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Personalization',
                      style: TextStyle(
                        color: isDarkMode ? lightTextColor : textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Dark Mode',
                            style: TextStyle(
                              color: isDarkMode ? lightTextColor : textColor,
                            )),
                        Switch.adaptive(
                            value: darkMode,
                            onChanged: (newValue) {
                              setModalState(() {
                                toggleDarkMode(newValue);
                              });
                            }),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            );
          });
        },
      );
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

              return modalPageAdd == 0
                  ? Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? offBlackColor : Colors.white54,
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
                                color: isDarkMode
                                    ? darkModeColor
                                    : Colors.grey[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          AddBTPSearch(searchWithFilters),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.74,
                            child: SingleChildScrollView(
                              child: FutureBuilder<List<BTP>>(
                                future: getAddBTPPageBTPs(
                                    search, filters, ordering),
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
                                      variation = double.parse(
                                          variation.toStringAsFixed(3));

                                      return TextButton(
                                          onPressed: () {
                                            setState(() {
                                              btp = asset;
                                              price = asset.value;
                                            });
                                            setModalState(() {
                                              modalPageAdd = 1;
                                            });
                                            // openAddBTPModal2();
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.transparent),
                                            padding: MaterialStateProperty.all(
                                                EdgeInsets.zero),
                                            overlayColor:
                                                MaterialStateProperty.all(
                                                    primaryColor
                                                        .withOpacity(0.3)),
                                            shape: MaterialStateProperty.all(
                                                const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.zero)),
                                          ),
                                          child: Column(children: [
                                            AddBTPInvestmentComponent(
                                              investmentName:
                                                  btpLess ?? "Unknown",
                                              investmentDetail: "$withBtp",
                                              cedola: "${cedola * 2}%",
                                              investmentValue: value,
                                              variation: variation,
                                            ),
                                            Divider(
                                              height: 1,
                                              color: isDarkMode
                                                  ? Colors.grey[800]
                                                  : Colors.grey[200],
                                            )
                                          ]));
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
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? offBlackColor : Colors.white54,
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
                                        setModalState(() {
                                          modalPageAdd = 0;
                                        });
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
                                const SizedBox(height: 18),
                                Center(
                                  child: Text(
                                    btp?.name.toUpperCase() ?? "",
                                    style: const TextStyle(
                                        fontSize: 24,
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
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
                                          backgroundColor: isDarkMode
                                              ? darkModeColor
                                              : Colors.white,
                                          initialDateTime: DateTime.now(),
                                          mode: CupertinoDatePickerMode.date,
                                          use24hFormat: true,
                                          onDateTimeChanged:
                                              (DateTime newDate) {
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
                                        isDarkMode
                                            ? darkModeColor
                                            : Colors.white),
                                    backgroundColor: MaterialStateProperty.all(
                                        isDarkMode
                                            ? darkModeColor
                                            : Colors.white),
                                    foregroundColor: isDarkMode
                                        ? MaterialStateProperty.all(
                                            lightTextColor)
                                        : MaterialStateProperty.all(textColor),
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.zero),
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
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.grey)),
                                const SizedBox(height: 10),
                                // add textfield
                                Material(
                                  elevation: 1,
                                  borderRadius: BorderRadius.circular(10),
                                  child: TextFormField(
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
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
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isDarkMode
                                          ? darkModeColor
                                          : Colors.white,
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
                                            Radius.circular(10)),
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
                                          const EdgeInsets.symmetric(
                                              horizontal: 15),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                    getString(
                                        'addBTPPageInvestmentSectionTitle'),
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
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
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
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: isDarkMode
                                          ? darkModeColor
                                          : Colors.white,
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
                                            Radius.circular(10)),
                                      ),
                                      hintText: getString(
                                          'addBTPPageInvestmentSectionPlaceholder'),
                                      hintStyle: TextStyle(
                                          fontSize: 16,
                                          color: isDarkMode
                                              ? lightTextColor
                                              : isDarkMode
                                                  ? lightTextColor
                                                  : textColor),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 15),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Text(getString('total'),
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: isDarkMode
                                            ? lightTextColor
                                            : textColor)),
                                const SizedBox(height: 10),
                                Text(getTotalInvestment(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 26,
                                        color: isDarkMode
                                            ? lightTextColor
                                            : textColor)),
                                const SizedBox(height: 10),
                              ],
                            ),
                            Column(
                              children: [
                                if (showErrorInvestmentTooLow)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                      getString(
                                          'addBTPPageInvestmentTooLowError'),
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 15),
                                    ),
                                  ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (price * investment >= 1000) {
                                      _addBTPToWallet();
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
                                    padding: MaterialStateProperty.all(
                                        EdgeInsets.zero),
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
          modalPageAdd = 0;
        });
      });
    }

    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : offWhiteColor,
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text('simpleBTP', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              size: 30,
            ),
            onPressed: () => openSettingsModal(),
          ),
          IconButton(
              icon: const Icon(
                Icons.add,
                size: 30,
              ),
              onPressed: () => openAddBTPModal()),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                primaryColor,
                isDarkMode ? secondaryColorDark : secondaryColor,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                getString('walletBalanceText'),
                style: TextStyle(
                    fontSize: 24,
                    color: isDarkMode ? lightTextColor : titleColor),
              ),
            ),
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
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Text(
                getString('walletMyAssets'),
                style: TextStyle(
                    fontSize: 24,
                    color: isDarkMode ? lightTextColor : titleColor),
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
                        investmentAmount: null,
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
                    final name = processString(asset['btp'].name);
                    // final percentage = name[0];
                    final withBtp = name[1];
                    final btpLess = name[2];
                    final double value =
                        asset['btp'].value * asset['investment'];
                    final double cedola = asset['btp'].cedola;
                    double variation =
                        (asset['btp'].value - asset['buyPrice']) /
                            asset['buyPrice'] *
                            100;
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
                              asset['investment'],
                              _deleteBTPFromWallet,
                            ),
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
                        child: WalletPageInvestmentComponent(
                          investmentName: btpLess ?? "Unknown",
                          investmentDetail: "$withBtp",
                          cedola: cedola,
                          investmentValue: value,
                          variation: variation,
                          expirationDate: date,
                          investmentAmount: asset['investment'],
                        ));
                  }).toList();
                  return Column(
                      children: investmentList
                          .map((e) => Column(
                                children: [
                                  e,
                                  Divider(
                                    height: 1,
                                    color: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
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
                style: TextStyle(
                    fontSize: 24,
                    color: isDarkMode ? lightTextColor : titleColor),
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
                        investmentValue: null,
                        investmentSoldDate: null,
                        investmentProfit: null,
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
                        getString('walletPageNoPastBTPsYet'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isDarkMode ? lightTextColor : textColor),
                      ),
                    );
                  }
                  final assets = snapshot.data!;
                  final investmentList = assets.map((asset) {
                    final name = processString(asset['btp'].name);
                    final btpLess = name[2];
                    DateTime soldDate = asset['soldDate'];
                    double soldPrice = asset['soldPrice'];
                    double buyPrice = asset['buyPrice'];

                    int cedoleCount = 0;
                    DateTime currentDate = soldDate;
                    while (asset['buyDate'].isBefore(currentDate)) {
                      cedoleCount++;
                      currentDate =
                          currentDate.subtract(const Duration(days: 365));
                    }

                    double profit =
                        (soldPrice - buyPrice) * asset['investment'];

                    double cedoleProfit = asset['btp'].cedola *
                        (cedoleCount - 1) *
                        asset['investment'];

                    profit += cedoleProfit;

                    return TextButton(
                        onPressed: () => openMyOldBTPDetailModal(
                            context,
                            isDarkMode,
                            asset['btp'],
                            asset['buyPrice'],
                            asset['soldPrice'],
                            asset['investment'],
                            asset['buyDate'],
                            asset['soldDate'],
                            cedoleProfit),
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
                        child: WalletPageOldInvestmentComponent(
                          investmentName: btpLess ?? "Unknown",
                          investmentValue: profit,
                          investmentSoldDate: asset['soldDate'],
                          investmentProfit:
                              ((asset['soldPrice'] * asset['investment']) +
                                  cedoleProfit),
                        ));
                  }).toList();
                  return Column(
                      children: investmentList
                          .map((e) => Column(
                                children: [
                                  e,
                                  Divider(
                                    height: 1,
                                    color: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
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
