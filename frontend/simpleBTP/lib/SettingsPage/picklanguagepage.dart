import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/components/appTopBar/apptopbar.dart';

class PickLanguagePage extends StatefulWidget {
  const PickLanguagePage({Key? key}) : super(key: key);

  @override
  State<PickLanguagePage> createState() => _PickLanguagePageState();
}

class _PickLanguagePageState extends State<PickLanguagePage> {
  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : Colors.white,
      appBar: appTopBar(getString('appTopBarPickLanguage'), null),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 10),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all<double>(2),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(vertical: 12)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18))),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          selectedLang ==
                                  availableLanguages.keys.elementAt(index)
                              ? primaryColorLight
                              : isDarkMode
                                  ? darkModeColor
                                  : Colors.white),
                      foregroundColor: MaterialStateProperty.all<Color>(
                          selectedLang ==
                                  availableLanguages.keys.elementAt(index)
                              ? Colors.white
                              : isDarkMode
                                  ? lightTextColor
                                  : textColor),
                    ),
                    child: Text(
                        availableLanguages[
                                availableLanguages.keys.elementAt(index)] ??
                            '',
                        style: const TextStyle(fontSize: 20)),
                    onPressed: () {
                      selectedLang = availableLanguages.keys.elementAt(index);
                      Hive.box('settings').put('language', selectedLang);
                      setState(() {});
                    },
                  ),
                );
              },
              itemCount: availableLanguages.length,
            ),
          ),
        ],
      ),
    );
  }
}
