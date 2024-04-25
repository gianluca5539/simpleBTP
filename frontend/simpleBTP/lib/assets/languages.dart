import 'package:hive/hive.dart';

export 'languages.dart';

String getString(String key) {
  // get selected language from hive
  Box box = Hive.box('settings');
  String lang = box.get('language', defaultValue: 'it');

  if (lang == 'it') {
    return italianLang[key] ?? key;
  }
  return ''; // actually this should never happen
}

Map<String, String> italianLang = {};
