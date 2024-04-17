import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum TimeWindow {
  oneDayCurrent,
  oneWeek,
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  fiveYears,
  tenYears,
}

// Convert TimeWindow enum to string for URL parameters
String timeWindowToString(TimeWindow timeWindow) {
  switch (timeWindow) {
    case TimeWindow.oneDayCurrent:
      return "OneDayCurrent";
    case TimeWindow.oneWeek:
      return "OneWeek";
    case TimeWindow.oneMonth:
      return "OneMonth";
    case TimeWindow.threeMonths:
      return "TreeMonths";
    case TimeWindow.sixMonths:
      return "SixMonths";
    case TimeWindow.oneYear:
      return "OneYear";
    case TimeWindow.fiveYears:
      return "FiveYears";
    case TimeWindow.tenYears:
      return "TenYears";
    default:
      return "OneDayCurrent";
  }
}

Future<Map<String, dynamic>> fetchBtpPrices(String isin, [TimeWindow timeWindow = TimeWindow.oneDayCurrent]) async {
  String timeWindowStr = timeWindowToString(timeWindow);
  String url = 'https://mercatiwdg.ilsole24ore.com/FinanzaMercati/api/TimeSeries/GetTimeSeries/$isin.MOT?timeWindow=$timeWindowStr&';
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print(data);
    return data;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<Map<String, String>> toDict(List<String> matches) async {
  Map<String, String> res = {};
  for (String match in matches) {
    String lowerMatch = match.toLowerCase();
    if (lowerMatch.startsWith("btp")) {
      res["btp"] = lowerMatch;
    } else if (lowerMatch.startsWith("cedola")) {
      List<String> split = lowerMatch.split(" ");
      if (split.length > 1) {
        res["cedola"] = split[1];
      }
    } else if (lowerMatch.startsWith("scadenza")) {
      res["scadenza"] = lowerMatch.split(" ")[1];
    } else if (lowerMatch.startsWith("ultimo")) {
      List<String> split = lowerMatch.split(" ");
      if (split.length > 1) {
        res["ultimo"] = split[1];
      }
    }
  }
  return res;
}

Future<Map<String, Map<String, String>>> fetchBtps([int page = 1]) async {
  Map<String, Map<String, String>> isinDict = {};

  List<String> tIsinList = [];
  var url = Uri.parse('https://www.borsaitaliana.it/borsa/obbligazioni/mot/btp/lista.html?lang=it&page=$page');
  var startTime = DateTime.now();
  var response = await http.get(url);
  String text = response.body;
  print('Page $page (${DateTime.now().difference(startTime).inMilliseconds}ms): ');

  int start = 0;
  while ((start = text.indexOf('IT000', start)) != -1) {
    String isin = text.substring(start, start + 12);
    if (!tIsinList.contains(isin)) {
      tIsinList.add(isin);
    }
    start += 12;
  }

  print('found ${tIsinList.length} ISINs');

  for (int i = 0; i < tIsinList.length; i++) {
    int isinStart = text.indexOf(tIsinList[i]);
    int end = (i + 1 < tIsinList.length) ? text.indexOf(tIsinList[i + 1]) : text.length;
    String subtext = text.substring(isinStart, end);
    RegExp exp = RegExp(r'<span class="t-text[^"]*">(.*?)</span>', dotAll: true);
    var matches = exp.allMatches(subtext).map((m) => m.group(1)!.trim()).toList();
    isinDict[tIsinList[i]] = await toDict(matches);
  }

  print('Total ISINs: ${isinDict.length} (raw: ${tIsinList.length})');
  return isinDict;
}
