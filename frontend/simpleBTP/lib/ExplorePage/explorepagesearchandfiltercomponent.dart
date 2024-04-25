// create a dart widget

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
              return SizedBox(
                height: 500,
                width: double.infinity,
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
                        const SizedBox(height: 10),
                        const Center(
                          child: Text('Personalizza la ricerca',
                              style: TextStyle(fontSize: 22, color: textColor)),
                        ),
                        const SizedBox(height: 25),
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
                        const SizedBox(height: 25),
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
                      ],
                    )),
              );
            });
          });
    }

    return Container(
      padding: const EdgeInsets.all(18),
      child: Row(
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
    );
  }
}
