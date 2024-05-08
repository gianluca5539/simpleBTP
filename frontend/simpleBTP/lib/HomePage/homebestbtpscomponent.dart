import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/ExplorePage/explorepage.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';

class HomeBestBTPsComponent extends StatelessWidget {
  const HomeBestBTPsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 22.0),
                  child: Text(
                    getString('homeBestBTPs'),
                    style: TextStyle(
                        color: isDarkMode ? lightTextColor : textColor,
                        fontSize: 24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 22.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      shadowColor:
                          MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExplorePage(),
                          ));
                    },
                    child: Text(getString('homeBestBTPsViewAllButton'),
                        style:
                             TextStyle(
                            color:
                                isDarkMode ? primaryColorLight : primaryColor,
                            fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
