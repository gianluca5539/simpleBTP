import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpinvestmentcomponent.dart';
import 'package:simpleBTP/WalletPage/AddBTPFirstPage/addbtpsearch.dart';
import 'package:simpleBTP/assets/colors.dart';
import 'package:simpleBTP/assets/defaults.dart';
import 'package:simpleBTP/assets/languages.dart';
import 'package:simpleBTP/btp_scraper.dart';
import 'package:simpleBTP/components/AppTopBar/apptopbar.dart';
import 'package:simpleBTP/db/db.dart';
import 'package:simpleBTP/db/hivemodels.dart';

class AddBTPSecondPage extends StatefulWidget {
  final BTP btp;
  const AddBTPSecondPage(this.btp, {Key? key}) : super(key: key);

  @override
  State<AddBTPSecondPage> createState() => _AddBTPSecondPageState();
}

class _AddBTPSecondPageState extends State<AddBTPSecondPage> {
  @override
  Widget build(BuildContext context) {
    Box box = Hive.box('settings');
    bool isDarkMode = box.get('darkMode', defaultValue: false);
    return Scaffold(
      backgroundColor: isDarkMode ? offBlackColor : Colors.white,
      appBar: AppTopBar(getString('appTopBarAddBTP'), null),
      body: SingleChildScrollView(
        child: Column(
          children: [Text(widget.btp.isin)],
        ),
      ),
    );
  }
}
