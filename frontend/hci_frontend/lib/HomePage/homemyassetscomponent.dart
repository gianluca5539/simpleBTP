import 'package:flutter/material.dart';
import 'package:hci_frontend/WalletPage/walletpage.dart';
import 'package:hci_frontend/assets/colors.dart';

class HomeMyAssetsComponent extends StatelessWidget {
  const HomeMyAssetsComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 22.0),
                  child: Text(
                    "I tuoi asset",
                    style: TextStyle(color: textColor, fontSize: 24),
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
                            builder: (context) => const WalletPage(),
                          ));
                    },
                    child: const Text("Visualizza tutto",
                        style: TextStyle(color: primaryColor, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
