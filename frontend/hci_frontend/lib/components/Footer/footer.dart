// create a bottom navigation bar component
import 'package:flutter/material.dart';
import 'package:hci_frontend/ExplorePage/explorepage.dart';
import 'package:hci_frontend/HomePage/homepage.dart';
import 'package:hci_frontend/WalletPage/walletpage.dart';
import 'package:hci_frontend/assets/colors.dart';

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
                Icon(Icons.home_outlined,
                    color: currentPage == 'home' ? primaryColor : textColor),
                Text('Home',
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
                Icon(Icons.account_balance_wallet_outlined,
                    color: currentPage == 'wallet' ? primaryColor : textColor),
                Text('Portafoglio',
                    style: TextStyle(
                        color: currentPage == 'wallet'
                            ? primaryColor
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
                Icon(Icons.explore_outlined,
                    color: currentPage == 'explore' ? primaryColor : textColor),
                Text('Esplora',
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
                Icon(Icons.settings_outlined,
                    color:
                        currentPage == 'settings' ? primaryColor : textColor),
                Text('Impostazioni',
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
