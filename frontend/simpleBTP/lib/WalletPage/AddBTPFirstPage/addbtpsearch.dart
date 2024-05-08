// create a dart widget
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/db/db.dart';

class AddBTPSearch extends StatefulWidget {
  final Function searchWithFilters;

  const AddBTPSearch(this.searchWithFilters, {Key? key}) : super(key: key);

  @override
  State<AddBTPSearch> createState() => _AddBTPSearchState();
}

class _AddBTPSearchState extends State<AddBTPSearch> {
  String search = '';

  Map<String, dynamic> filters = defaultAddBTPFilters;

  Map<String, dynamic> ordering = defaultAddBTPOrdering;

  double maxYear = maxBTPExpirationDate.year.toDouble(); // need these to work

  void executeOrdering(String orderby, String order, BuildContext context) {
    setState(() {
      ordering = {'orderBy': orderby, 'order': order};
    });
    widget.searchWithFilters(search, filters, ordering);
    Navigator.pop(context);
  }

  FontWeight getFontWeightForItem(String orderBy, String order) {
    if (ordering['orderBy'] == orderBy && ordering['order'] == order) {
      return FontWeight.w800;
    }
    return FontWeight.normal;
  }

  Color getColorForItem(String orderBy, String order) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    if (ordering['orderBy'] == orderBy && ordering['order'] == order) {
      return isDarkMode ? primaryColorLight : primaryColor;
    }
    return isDarkMode ? primaryColorLight : primaryColor;
  }

  String getOrderByButtonText() {
    String orderBy = ordering['orderBy'];
    String order = ordering['order'];
    String orderText = '';
    if (orderBy == 'value') {
      orderText = '${getString('addBTPPageOrderByValue')} ';
    } else if (orderBy == 'cedola') {
      orderText = '${getString('addBTPPageOrderByCedola')} ';
    } else if (orderBy == 'expirationDate') {
      orderText = '${getString('addBTPPageOrderByExpirationDate')} ';
    }
    if (order == 'asc') {
      orderText += '↑';
    } else {
      orderText += '↓';
    }
    return orderText;
  }

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    void openFilterModal() {
      if (minBTPCedola > maxBTPCedola) {
        return;
      }
      double minBTPCedolaYearly = minBTPCedola * 2;
      double maxBTPCedolaYearly = maxBTPCedola * 2;
      showModalBottomSheet(
          context: context,
          isDismissible: true,
          builder: (BuildContext ctx) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: 500,
                width: double.infinity,
                // set background color
                decoration: BoxDecoration(
                    color: isDarkMode ? offBlackColor : offWhiteColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    )),
                child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Center(
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
                        const SizedBox(height: 15),
                        Center(
                          child: Text(getString('addBTPPageFilterTitle'),
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? lightTextColor : textColor)),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(getString('addBTPPageValueFilterTitle'),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: isDarkMode
                                        ? lightTextColor
                                        : textColor)),
                            const Spacer(),
                            Text(
                                '€${filters['minVal']?.toStringAsFixed(2) ?? minBTPVal} - €${filters['maxVal']?.toStringAsFixed(2) ?? maxBTPVal}',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? primaryColorLight
                                        : primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Center(
                          child: RangeSlider(
                            values: RangeValues(
                                filters['minValue'] ?? minBTPVal,
                                filters['maxValue'] ?? maxBTPVal),
                            min: minBTPVal,
                            max: maxBTPVal,
                            divisions: 100,
                            labels: RangeLabels(
                                filters['minValue']?.toStringAsFixed(2) ??
                                    minBTPVal.toStringAsFixed(2),
                                filters['maxValue']?.toStringAsFixed(2) ??
                                    maxBTPVal.toStringAsFixed(2)),
                            onChanged: (RangeValues values) {
                              setState(() {
                                filters['minValue'] = values.start;
                                filters['maxValue'] = values.end;
                              });
                            },
                            onChangeEnd: (RangeValues values) {
                              widget.searchWithFilters(
                                  search, filters, ordering);
                            },
                            activeColor:
                                isDarkMode ? primaryColorLight : primaryColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(getString('addBTPPageCedolaFilterTitle'),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: isDarkMode
                                        ? lightTextColor
                                        : textColor)),
                            const Spacer(),
                            Text(
                                '${(filters['minCedola']?.toStringAsFixed(2) ?? minBTPCedolaYearly)}% - ${(filters['maxCedola']?.toStringAsFixed(2) ?? maxBTPCedolaYearly)}%',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? primaryColorLight
                                        : primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Center(
                          child: RangeSlider(
                            values: RangeValues(
                                (filters['minCedola'] ?? minBTPCedolaYearly),
                                (filters['maxCedola'] ?? maxBTPCedolaYearly)),
                            min: (minBTPCedolaYearly),
                            max: (maxBTPCedolaYearly),
                            divisions: 50,
                            labels: RangeLabels(
                                filters['minCedola']?.toStringAsFixed(2) ??
                                    (minBTPCedolaYearly).toStringAsFixed(2),
                                filters['maxCedola']?.toStringAsFixed(2) ??
                                    (maxBTPCedolaYearly).toStringAsFixed(2)),
                            onChanged: (RangeValues values) {
                              setState(() {
                                filters['minCedola'] = values.start;
                                filters['maxCedola'] = values.end;
                              });
                            },
                            onChangeEnd: (RangeValues values) {
                              widget.searchWithFilters(
                                  search, filters, ordering);
                            },
                            activeColor:
                                isDarkMode ? primaryColorLight : primaryColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                                getString(
                                    'addBTPPageExpirationDateFilterTitle'),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: isDarkMode
                                        ? lightTextColor
                                        : textColor)),
                            const Spacer(),
                            Text(
                                '${filters['minExpirationDate']?.year ?? minBTPExpirationDate.year} - ${filters['maxExpirationDate']?.year ?? maxBTPExpirationDate.year}',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: isDarkMode
                                        ? primaryColorLight
                                        : primaryColor)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Center(
                            child: RangeSlider(
                          values: RangeValues(
                              (filters['minExpirationDate']?.year ??
                                      minBTPExpirationDate.year)
                                  .toDouble(),
                              (filters['maxExpirationDate']?.year ??
                                      maxBTPExpirationDate.year)
                                  .toDouble()),
                          min: minBTPExpirationDate.year.toDouble(),
                          max: maxBTPExpirationDate.year.toDouble(),
                          divisions: maxBTPExpirationDate.year -
                              minBTPExpirationDate.year,
                          labels: RangeLabels(
                              (filters['minExpirationDate']?.year ??
                                      minBTPExpirationDate.year)
                                  .toString(),
                              (filters['maxExpirationDate']?.year ??
                                      maxBTPExpirationDate.year)
                                  .toString()),
                          onChanged: (RangeValues values) {
                            setState(() {
                              filters['minExpirationDate'] =
                                  DateTime(values.start.toInt(), 1, 1);
                              filters['maxExpirationDate'] =
                                  DateTime(values.end.toInt(), 12, 31);
                            });
                          },
                          onChangeEnd: (RangeValues values) {
                            widget.searchWithFilters(search, filters, ordering);
                          },
                          activeColor:
                              isDarkMode ? primaryColorLight : primaryColor,
                        )),
                        const SizedBox(height: 25),
                        Center(
                          child: SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              onPressed: () {
                                // actually already searched
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 3,
                                // set white background color
                                surfaceTintColor:
                                    isDarkMode ? darkModeColor : Colors.white,
                                backgroundColor:
                                    isDarkMode ? darkModeColor : Colors.white,
                                shadowColor: isDarkMode
                                    ? Colors.transparent
                                    : Colors.grey.withOpacity(0.2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                              child: Text(
                                  getString('addBTPPageApplyFiltersButton'),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode
                                          ? primaryColorLight
                                          : primaryColor)),
                            ),
                          ),
                        ),
                      ],
                    )),
              );
            });
          });
    }

    return Container(
      padding: const EdgeInsets.only(top: 0, left: 18, right: 18, bottom: 10),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: isDarkMode ? darkModeColor : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.transparent
                            : Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    onChanged: (value) {
                      search = value;
                      widget.searchWithFilters(search, filters, ordering);
                    },
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
                            const BorderRadius.all(Radius.circular(15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: isDarkMode ? darkModeColor : Colors.white),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                      ),
                      hintText: getString('addBTPSearchPlaceholder'),
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
              ),
              const SizedBox(width: 10),
              // add an icon button
              IconButton(
                onPressed: () => openFilterModal(),
                icon: SvgPicture.asset(
                  'lib/assets/icons/filter.svg', // Path to the SVG asset
                  colorFilter: ColorFilter.mode(
                      isDarkMode
                          ? primaryColorLight
                          : primaryColor, // This is the color filter
                      BlendMode
                          .srcIn // This blend mode is typically used for tinting icons
                      ),
                  width: 38, // You can specify the size as needed
                  height: 38,
                ),
                padding: const EdgeInsets.all(0),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getString('addBTPPageResults'),
                  style: TextStyle(
                      fontSize: 20,
                      color: isDarkMode
                          ? lightTextColor
                          : isDarkMode
                              ? lightTextColor
                              : textColor),
                ),
                // show a cupertino picker
                GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness:
                                isDarkMode ? Brightness.dark : Brightness.light,
                          ),
                          child: CupertinoActionSheet(
                            actions: <Widget>[
                              CupertinoActionSheetAction(
                                child: Text(
                                  '${getString('addBTPPageOrderByValueButton')} ↑',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: getColorForItem('value', 'asc'),
                                      fontWeight:
                                          getFontWeightForItem('value', 'asc')),
                                ),
                                onPressed: () {
                                  executeOrdering('value', 'asc', context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text(
                                    '${getString('addBTPPageOrderByValueButton')} ↓',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: getColorForItem('value', 'desc'),
                                        fontWeight: getFontWeightForItem(
                                            'value', 'desc'))),
                                onPressed: () {
                                  executeOrdering('value', 'desc', context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text(
                                    '${getString('addBTPPageOrderByCedolaButton')} ↑',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: getColorForItem('cedola', 'asc'),
                                        fontWeight: getFontWeightForItem(
                                            'cedola', 'asc'))),
                                onPressed: () {
                                  executeOrdering('cedola', 'asc', context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text(
                                    '${getString('addBTPPageOrderByCedolaButton')} ↓',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            getColorForItem('cedola', 'desc'),
                                        fontWeight: getFontWeightForItem(
                                            'cedola', 'desc'))),
                                onPressed: () {
                                  executeOrdering('cedola', 'desc', context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text(
                                    '${getString('addBTPPageOrderByExpirationDateButton')} ↑',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: getColorForItem(
                                            'expirationDate', 'asc'),
                                        fontWeight: getFontWeightForItem(
                                            'expirationDate', 'asc'))),
                                onPressed: () {
                                  executeOrdering(
                                      'expirationDate', 'asc', context);
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text(
                                    '${getString('addBTPPageOrderByExpirationDateButton')} ↓',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: getColorForItem(
                                            'expirationDate', 'desc'),
                                        fontWeight: getFontWeightForItem(
                                            'expirationDate', 'desc'))),
                                onPressed: () {
                                  executeOrdering(
                                      'expirationDate', 'desc', context);
                                },
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(getString('cancel'),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.red)),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    "${getString('addBTPPageOrder')}: ${getOrderByButtonText()}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? primaryColorLight : primaryColor),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
