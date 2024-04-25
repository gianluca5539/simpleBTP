// create a dart widget

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/db/db.dart';

class ExplorePageSearchAndFilterComponent extends StatefulWidget {
  final Function searchWithFilters;

  const ExplorePageSearchAndFilterComponent(this.searchWithFilters, {Key? key})
      : super(key: key);

  @override
  State<ExplorePageSearchAndFilterComponent> createState() =>
      _ExplorePageSearchAndFilterComponentState();
}

class _ExplorePageSearchAndFilterComponentState
    extends State<ExplorePageSearchAndFilterComponent> {
  String search = '';

  Map<String, dynamic> filters = defaultExploreFilters;

  Map<String, dynamic> ordering = defaultExploreOrdering;

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
      return FontWeight.bold;
    }
    return FontWeight.normal;
  }

  String getOrderByButtonText() {
    String orderBy = ordering['orderBy'];
    String order = ordering['order'];
    String orderText = '';
    if (orderBy == 'value') {
      orderText = 'Valore ';
    } else if (orderBy == 'cedola') {
      orderText = 'Cedola ';
    } else if (orderBy == 'expirationDate') {
      orderText = 'Scadenza ';
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
                decoration: const BoxDecoration(
                    color: offWhiteColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
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
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Center(
                          child: Text('Personalizza la ricerca',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textColor)),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Text('Valore di mercato',
                                style:
                                    TextStyle(fontSize: 18, color: textColor)),
                            const Spacer(),
                            Text(
                                '€${filters['minVal']?.toStringAsFixed(2) ?? minBTPVal} - €${filters['maxVal']?.toStringAsFixed(2) ?? maxBTPVal}',
                                style: const TextStyle(
                                    fontSize: 15, color: primaryColor)),
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
                            activeColor: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Text('Cedola annuale',
                                style:
                                    TextStyle(fontSize: 18, color: textColor)),
                            const Spacer(),
                            Text(
                                '${(filters['minCedola']?.toStringAsFixed(2) ?? minBTPCedolaYearly)}% - ${(filters['maxCedola']?.toStringAsFixed(2) ?? maxBTPCedolaYearly)}%',
                                style: const TextStyle(
                                    fontSize: 15, color: primaryColor)),
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
                            activeColor: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Text('Data di scadenza',
                                style:
                                    TextStyle(fontSize: 18, color: textColor)),
                            const Spacer(),
                            Text(
                                '${filters['minExpirationDate']?.year ?? minBTPExpirationDate.year} - ${filters['maxExpirationDate']?.year ?? maxBTPExpirationDate.year}',
                                style: const TextStyle(
                                    fontSize: 15, color: primaryColor)),
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
                          activeColor: primaryColor,
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
                                surfaceTintColor: Colors.white,
                                shadowColor: Colors.grey.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                              child: const Text('Applica',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor)),
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
      padding: const EdgeInsets.only(top: 18, left: 18, right: 18, bottom: 10),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      search = value;
                      widget.searchWithFilters(search, filters, ordering);
                    },
                    style: const TextStyle(fontSize: 18),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      hintText: 'Cerca uno strumento...',
                      hintStyle: TextStyle(fontSize: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                      border: OutlineInputBorder(
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
                  colorFilter: const ColorFilter.mode(
                      primaryColor,
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
                const Text(
                  'Risultati',
                  style: TextStyle(fontSize: 20),
                ),
                // show a cupertino picker
                GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoActionSheet(
                          title: const Text(
                            'Ordina i risultati per:',
                            style: TextStyle(fontSize: 20, color: textColor),
                          ),
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                              child: Text(
                                'Valore di mercato ↑',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: primaryColor,
                                    fontWeight:
                                        getFontWeightForItem('value', 'asc')),
                              ),
                              onPressed: () {
                                executeOrdering('value', 'asc', context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text('Valore di mercato ↓',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: getFontWeightForItem(
                                          'value', 'desc'))),
                              onPressed: () {
                                executeOrdering('value', 'desc', context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text('Cedola annuale ↑',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: getFontWeightForItem(
                                          'cedola', 'asc'))),
                              onPressed: () {
                                executeOrdering('cedola', 'asc', context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text('Cedola annuale ↓',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: getFontWeightForItem(
                                          'cedola', 'desc'))),
                              onPressed: () {
                                executeOrdering('cedola', 'desc', context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text('Data di scadenza ↑',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: getFontWeightForItem(
                                          'expirationDate', 'asc'))),
                              onPressed: () {
                                executeOrdering(
                                    'expirationDate', 'asc', context);
                              },
                            ),
                            CupertinoActionSheetAction(
                              child: Text('Data di scadenza ↓',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor,
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
                            child: const Text('Annulla',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.red)),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    "Ordine: ${getOrderByButtonText()}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor),
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
