import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/SettingsPage/picklanguagepage.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/components/Footer/footer.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    Box settings = Hive.box('settings');
    darkMode = settings.get('darkMode', defaultValue: false);
  }

  void toggleDarkMode(value) {
    setState(() {
      darkMode = value;
      Box settings = Hive.box('settings');
      settings.put('darkMode', value);
    });
  }

  void openPickLanguagePage(BuildContext context) {
    Navigator.push(
        context,
        (MaterialPageRoute(builder: (context) {
          return const PickLanguagePage();
        }))).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : offWhiteColor,
      appBar: AppTopBar(getString('appTopBarSettings'), null),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              getString('settingsPageAccountTitle'),
              style: TextStyle(
                  fontSize: 22, color: isDarkMode ? lightTextColor : textColor),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(top: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? darkModeColor : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.transparent
                        : Colors.grey.withOpacity(0.25),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      elevation: 0.0,
                      foregroundColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      backgroundColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      shadowColor: isDarkMode ? darkModeColor : Colors.white,
                      surfaceTintColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      animationDuration: const Duration(milliseconds: 500),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getString('settingsPageWalletBackupButton'),
                          style:
                               const TextStyle(
                              color: Colors
                                  .grey, // isDarkMode ? lightTextColor : textColor,
                              fontSize: 20),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Colors
                                .grey, // isDarkMode ? lightTextColor : textColor,
                            size: 30)
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      elevation: 0.0,
                      foregroundColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      backgroundColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      shadowColor: isDarkMode ? darkModeColor : Colors.white,
                      surfaceTintColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      animationDuration: const Duration(milliseconds: 500),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getString('settingsPageWalletBackupRestoreButton'),
                          style:
                               const TextStyle(
                              color: Colors
                                  .grey, //isDarkMode ? lightTextColor : textColor,
                              fontSize: 20),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Colors
                                .grey, // isDarkMode ? lightTextColor : textColor,
                            size: 30)
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      elevation: 0.0,
                      foregroundColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      backgroundColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      shadowColor: isDarkMode ? darkModeColor : Colors.white,
                      surfaceTintColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      animationDuration: const Duration(milliseconds: 500),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getString('settingsPageWalletDeleteButton'),
                          style:
                                const TextStyle(
                              color: Colors
                                  .grey, // isDarkMode ? lightTextColor : textColor,
                              fontSize: 20),
                        ),
                        const Icon(Icons.chevron_right,
                            color: Colors
                                .grey, // isDarkMode ? lightTextColor : textColor,
                            size: 30)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              getString('settingsPagePersonalizationTitle'),
              style: TextStyle(
                  fontSize: 22, color: isDarkMode ? lightTextColor : textColor),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(top: 5),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? darkModeColor : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getString('settingsPageDarkModeButton'),
                          style:
                               TextStyle(
                              color: isDarkMode ? lightTextColor : textColor,
                              fontSize: 20),
                        ),
                        SizedBox(
                          height: 32,
                          child: Switch.adaptive(
                              value: darkMode,
                              onChanged: (newValue) {
                                toggleDarkMode(newValue);
                              }),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      openPickLanguagePage(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      elevation: 0.0,
                      foregroundColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      backgroundColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      shadowColor: isDarkMode ? darkModeColor : Colors.white,
                      surfaceTintColor:
                          isDarkMode ? darkModeColor : Colors.white,
                      animationDuration: const Duration(milliseconds: 500),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getString('settingsPageLanguageButton'),
                          style:
                               TextStyle(
                              color: isDarkMode ? lightTextColor : textColor,
                              fontSize: 20),
                        ),
                        Icon(Icons.chevron_right,
                            color: isDarkMode ? lightTextColor : textColor,
                            size: 30)
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Footer('settings'),
    );
  }
}
