// create a dart widget

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simpleBTP/assets/colors.dart';

class ExplorePageSearchAndFilterComponent extends StatelessWidget {
  final Function searchWithFilters;
  String search = '';
  Map<String, dynamic> filters = {};

  ExplorePageSearchAndFilterComponent(this.searchWithFilters, {Key? key})
      : super(key: key);

  void openFilterModal(BuildContext ctx) {
    showModalBottomSheet(
        isDismissible: true,
        context: ctx,
        builder: (BuildContext context) {
          return SizedBox(
            height: 500,
            width: double.infinity,
            child: Column(
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
              ],
            ),
          );
        }).then((value) => searchWithFilters(search, filters));
  }

  @override
  Widget build(BuildContext context) {
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
                  searchWithFilters(search, filters);
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
            onPressed: () => openFilterModal(context),
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
