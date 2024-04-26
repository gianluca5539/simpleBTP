import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpinvestmentcomponent.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpsearch.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/db/db.dart';
import 'package:simpleBTP/db/hivemodels.dart';

class AddBTPSecondPage extends StatefulWidget {
  final BTP btp;
  const AddBTPSecondPage(this.btp, {Key? key}) : super(key: key);

  @override
  State<AddBTPSecondPage> createState() => _AddBTPSecondPageState();
}

class _AddBTPSecondPageState extends State<AddBTPSecondPage> {

  DateTime? selectedDate;
  double? price;
  double? investment;

  String get purchaseDate {
    if (selectedDate == null) {
      return getString('addBTPPageSelectDateButton');
    }
    return "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
  }

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
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  void _addBTPToWallet() {
    if (selectedDate == null || price == null || investment == null) {
      return;
    }
    addBTPToWallet(widget.btp.isin, selectedDate!, price!, investment!);
  }
  

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : offWhiteColor,
      appBar: AppTopBar(widget.btp.name.toUpperCase(), null),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 165,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(getString('addBTPPageDateSectionTitle'),
                      style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode ? lightTextColor : textColor)),
                  const SizedBox(height: 15),
                  Center(
                      child: ElevatedButton(
                    onPressed: () => _showDatePickerDialog(
                      CupertinoDatePicker(
                        initialDateTime: DateTime.now(),
                        mode: CupertinoDatePickerMode.date,
                        use24hFormat: true,
                        onDateTimeChanged: (DateTime newDate) {
                          setState(() {
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
                      style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode ? lightTextColor : textColor)),
                  const SizedBox(height: 10),
                  // add textfield
                  Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(10),
                    child: TextField(
                      onChanged: (value) => price = double.tryParse(value),
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
                        fillColor: isDarkMode ? darkModeColor : Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDarkMode ? darkModeColor : Colors.white),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDarkMode ? darkModeColor : Colors.white),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        hintText:
                            getString('addBTPPagePriceSectionPlaceholder'),
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
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(getString('addBTPPageInvestmentSectionTitle'),
                      style: TextStyle(
                          fontSize: 20,
                          color: isDarkMode ? lightTextColor : textColor)),
                  const SizedBox(height: 10),
                  // add textfield
                  Material(
                    elevation: 1,
                    borderRadius: BorderRadius.circular(10),
                    child: TextField(
                      //onChanged: (value) => investment = double.tryParse(value),
                      keyboardType: TextInputType.number,
                      // allow only numbers and one comma with two decimal places (max)
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
                        fillColor: isDarkMode ? darkModeColor : Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDarkMode ? darkModeColor : Colors.white),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDarkMode ? darkModeColor : Colors.white),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        hintText:
                            getString('addBTPPageInvestmentSectionPlaceholder'),
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
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _addBTPToWallet(),
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                      const Size(double.infinity, 45)),
                  elevation: MaterialStateProperty.all(1),
                  backgroundColor: MaterialStateProperty.all(
                      isDarkMode ? primaryColorLight : primaryColor),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  overlayColor:
                      MaterialStateProperty.all(primaryColor.withOpacity(0.3)),
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
                child: Text(
                  getString('addBTPPageAddButton'),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: lightTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
