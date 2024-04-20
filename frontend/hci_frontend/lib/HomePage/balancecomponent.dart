import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hci_frontend/assets/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BalanceComponent extends StatelessWidget {
  late double? balance;
  late double? variation;

  BalanceComponent({super.key, required this.balance, required this.variation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: const Offset(0, 3),
                ),
              ]),
          width: 0.9 * MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
            child: Column(
              // align text to the left
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 17.0, right: 17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Il tuo investimento",
                        style: TextStyle(color: textColor, fontSize: 22),
                      ),
                      Skeletonizer(
                          enabled: variation == null,
                          child: Text(
                            "${variation?.toStringAsFixed(2)}%",
                            style: TextStyle(
                                color: (variation ?? 0) > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 22),
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 17.0, right: 17.0, top: 5.0),
                  child: Skeletonizer(
                      enabled: balance == null,
                      child: Text(
                        "€${balance == null ? '----' : ''}${balance?.toStringAsFixed(2).replaceAll(".", ",").replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}",
                    style: const TextStyle(color: textColor, fontSize: 34),
                      )),
                      
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
