// create a bottom navigation bar component
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/ExplorePage/explorepage.dart';
import 'package:simpleBTP/HomePage/homepage.dart';
import 'package:simpleBTP/SettingsPage/settingspage.dart';
import 'package:simpleBTP/WalletPage/walletpage.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';

class Footer extends StatelessWidget {
  // create a variable to store the current page
  late final String currentPage;

  final ButtonStyle footerButtonStyle = ButtonStyle(
    overlayColor: MaterialStateProperty.all(Colors.transparent),
    backgroundColor: MaterialStateProperty.all(Colors.transparent),
    shadowColor: MaterialStateProperty.all(Colors.transparent),
    elevation: MaterialStateProperty.all(0),
    padding: MaterialStateProperty.all(EdgeInsets.zero),
  );

  Footer(this.currentPage, {super.key});

  void navigateTo(BuildContext context, Widget page) {
    // push the new page removing all history
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => page),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return BottomAppBar(
      height: 65,
      color: isDarkMode ? offBlackColor : offWhiteColor,
      padding: const EdgeInsets.only(top: 17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // create a button with a column as child
          ElevatedButton(
            onPressed: () {
              navigateTo(context, const HomePage());
            },
            style: footerButtonStyle,
            child: Column(
              children: [
                SvgPicture.asset(
                  'lib/assets/icons/home.svg', // Path to the SVG asset
                  colorFilter: ColorFilter.mode(
                      currentPage == 'home'
                          ? primaryColorLight
                          : isDarkMode
                              ? footerLightTextColor
                              : textColor, // Apply dynamic coloring
                      BlendMode
                          .srcIn // This blend mode is typically used for tinting icons
                      ),
                  width: 24, // You can specify the size as needed
                  height: 24,
                ),
                Text(getString('appBottomBarHome'),
                    style: TextStyle(
                        color:
                            currentPage == 'home'
                            ? primaryColorLight
                            : isDarkMode
                                ? footerLightTextColor
                                : textColor)),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              navigateTo(context, const WalletPage());
            },
            style: footerButtonStyle,
            child: Column(
              children: [
                SvgPicture.asset(
                  'lib/assets/icons/wallet.svg', // Path to the SVG asset
                  colorFilter: ColorFilter.mode(
                      currentPage == 'wallet'
                          ? primaryColorLight
                          : isDarkMode
                              ? footerLightTextColor
                              : textColor, // Apply dynamic coloring
                      BlendMode
                          .srcIn // This blend mode is typically used for tinting icons
                      ),
                  width: 24, // You can specify the size as needed
                  height: 24,
                ),
                Text(getString('appBottomBarWallet'),
                    style: TextStyle(
                        color: currentPage == 'wallet'
                            ? primaryColorLight
                            : isDarkMode
                                ? footerLightTextColor
                                : textColor)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              navigateTo(context, const ExplorePage());
            },
            style: footerButtonStyle,
            child: Column(
              children: [
                SvgPicture.asset(
                  'lib/assets/icons/explore.svg', // Path to the SVG asset
                  colorFilter: ColorFilter.mode(
                      currentPage == 'explore'
                          ? primaryColorLight
                          : isDarkMode
                              ? footerLightTextColor
                              : textColor, // Apply dynamic coloring
                      BlendMode
                          .srcIn // This blend mode is typically used for tinting icons
                      ),
                  width: 24, // You can specify the size as needed
                  height: 24,
                ),
                Text(getString('appBottomBarExplore'),
                    style: TextStyle(
                        color: currentPage == 'explore'
                            ? primaryColorLight
                            : isDarkMode
                                ? footerLightTextColor
                                : textColor)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              navigateTo(context, const SettingsPage());
            },
            style: footerButtonStyle,
            child: Column(
              children: [
                SvgPicture.asset(
                  'lib/assets/icons/settings.svg', // Path to the SVG asset
                  colorFilter: ColorFilter.mode(
                      currentPage == 'settings'
                          ? primaryColorLight
                          : isDarkMode
                              ? footerLightTextColor
                              : textColor, // Apply dynamic coloring
                      BlendMode
                          .srcIn // This blend mode is typically used for tinting icons
                      ),
                  width: 24, // You can specify the size as needed
                  height: 24,
                ),
                Text(getString('appBottomBarSettings'),
                    style: TextStyle(
                        color: currentPage == 'settings'
                            ? primaryColorLight
                            : isDarkMode
                                ? footerLightTextColor
                                : textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
