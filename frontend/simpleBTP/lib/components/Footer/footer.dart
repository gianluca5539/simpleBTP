// create a bottom navigation bar component
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simpleBTP/ExplorePage/explorepage.dart';
import 'package:simpleBTP/HomePage/homepage.dart';
import 'package:simpleBTP/WalletPage/walletpage.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';

class Footer extends StatelessWidget {
  // create a variable to store the current page
  late String currentPage;

  ButtonStyle footerButtonStyle = ButtonStyle(
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
    return BottomAppBar(
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
                          ? primaryColor
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
                            currentPage == 'home' ? primaryColor : textColor)),
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
                          ? primaryColor
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
                            ? primaryColor
                            : textColor)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              navigateTo(context, ExplorePage());
            },
            style: footerButtonStyle,
            child: Column(
              children: [
                SvgPicture.asset(
                  'lib/assets/icons/explore.svg', // Path to the SVG asset
                  colorFilter: ColorFilter.mode(
                      currentPage == 'explore'
                          ? primaryColor
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
                            ? primaryColor
                            : textColor)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              navigateTo(context, const HomePage());
            },
            style: footerButtonStyle,
            child: Column(
              children: [
                SvgPicture.asset(
                  'lib/assets/icons/settings.svg', // Path to the SVG asset
                  colorFilter: ColorFilter.mode(
                      currentPage == 'settings'
                          ? primaryColor
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
                            ? primaryColor
                            : textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
