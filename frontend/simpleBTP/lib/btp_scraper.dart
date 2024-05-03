import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';

import 'package:simpleBTP/db/db.dart';

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

List<String?> processString(String inputString) {
  // Define the regex pattern to find the percentage
  RegExp percentagePattern = RegExp(r"\b\d+(?:\.\d+)?%");

  // Patterns to remove specific substrings
  List<String> substringsToRemove = ["btpi-", "btpi", "btp-", "btp "];

  // Replace comma with dot for standard percentage format
  inputString = inputString.replaceAll(",", ".");

  // Find the percentage using the regex pattern
  String? percentage = percentagePattern.firstMatch(inputString)?.group(0);

  // Erase the found percentage from the original string
  String withBtp = inputString.replaceAll(percentagePattern, '');
  withBtp = withBtp.replaceAll(RegExp(' +'), ' ').trim();

  String btpless = withBtp;

  // Remove specific substrings
  for (String pattern in substringsToRemove) {
    btpless = btpless.replaceAll(RegExp(pattern), '');
  }

  // Collapse double spaces
  btpless = btpless.replaceAll(RegExp(' +'), ' ').trim();

  return [percentage, withBtp, btpless];
}

Future<Map<String, dynamic>> fetchBtpPrices(String isin,
    [TimeWindow timeWindow = TimeWindow.oneWeek]) async {
  String timeWindowStr = timeWindowToString(timeWindow);
  String url =
      'https://mercatiwdg.ilsole24ore.com/FinanzaMercati/api/TimeSeries/GetTimeSeries/$isin.MOT?timeWindow=$timeWindowStr&';
  var response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
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

Future<Map<String, Map<String, String>>> fetchBtps() async {
  int page = 1;
  Map<String, Map<String, String>> isinDict = {};
  bool shouldContinue = true;

  while (shouldContinue) {
    // start timestamp
    DateTime start = DateTime.now();
    List<Future<void>> batchFetchTasks = [];
    for (int i = 0; i < 5 && shouldContinue; i++) {
      batchFetchTasks.add(fetchAndProcessPage(page, isinDict, (hasIsins) {
        if (!hasIsins) {
          shouldContinue = false;
        }
      }));
      page++;
    }

    await Future.wait(batchFetchTasks);
    if (batchFetchTasks.isEmpty) {
      break;
    }
    print(
        "Batch fetch took ${DateTime.now().difference(start).inSeconds} seconds");
  }

  print('Total ISINs: ${isinDict.length}');
  return isinDict;
}

Future<void> fetchAndProcessPage(int page,
    Map<String, Map<String, String>> isinDict, Function(bool) callback) async {
  try {
    print("Fetching page $page");
    var url = Uri.parse(
        'https://www.borsaitaliana.it/borsa/obbligazioni/mot/btp/lista.html?lang=it&page=$page');
    var response = await http.get(url);
    print("Fetched page $page");
    if (response.statusCode == 200) {
      var hasIsins = await processPageResponse(response.body, isinDict);
      callback(hasIsins);
    } else {
      print('Error fetching page $page: ${response.statusCode}');
      callback(false);
    }
  } catch (e) {
    print('Exception during fetch for page $page: $e');
    callback(false);
  }
}

Future<bool> processPageResponse(
    String text, Map<String, Map<String, String>> isinDict) async {
  int start = 0;
  List<String> tIsinList = [];
  while ((start = text.indexOf('IT000', start)) != -1) {
    String isin = text.substring(start, start + 12);
    if (!tIsinList.contains(isin)) {
      tIsinList.add(isin);
    }
    start += 12;
  }

  if (tIsinList.isEmpty) {
    return false;
  }

  for (int i = 0; i < tIsinList.length; i++) {
    int isinStart = text.indexOf(tIsinList[i]);
    int end = (i + 1 < tIsinList.length)
        ? text.indexOf(tIsinList[i + 1])
        : text.length;
    String subtext = text.substring(isinStart, end);
    RegExp exp =
        RegExp(r'<span class="t-text[^"]*">(.*?)</span>', dotAll: true);
    var matches =
        exp.allMatches(subtext).map((m) => m.group(1)!.trim()).toList();
    isinDict[tIsinList[i]] = await toDict(matches);
  }

  return true;
}

Future<List<Map<String, dynamic>>> fetchMyBTPHistories(
    [TimeWindow span = TimeWindow.oneWeek]) async {
  List<Map<String, dynamic>> myBTPs = await getMyBTPs();
  List<Future<Map<String, dynamic>>> priceHistories = [];

  for (var btp in myBTPs) {
    print("Fetching history for ${btp['isin']}");
    Future<Map<String, dynamic>> priceHistory =
        fetchWithRetry(btp['isin'], 3, span) // Retry up to 3 times
            .then((data) {
      btp['priceHistory'] = data; // Enrich the BTP data with price history
      print('Fetched price data for ISIN ${btp['isin']}');
      return btp;
    }).catchError((e) {
      print(
          'Failed to fetch price data for ISIN ${btp['isin']} after retries: $e');
      return btp; // Return BTP data without price history on failure
    });
    priceHistories.add(priceHistory);
  }

  var res = await Future.wait(
      priceHistories); // Wait for all price histories to complete
  return res;
}

Future<Map<String, dynamic>> fetchWithRetry(String isin, int retries,
    [TimeWindow span = TimeWindow.oneWeek]) async {
  int attempts = 0;
  while (attempts < retries) {
    try {
      return await fetchBtpPrices(isin, span);
    } catch (e) {
      if (attempts >= retries - 1) {
        rethrow; // Throw the last exception if we've used up all retries
      }
      attempts++;
      await Future.delayed(const Duration(seconds: 2)); // Wait before retrying
      print('Retrying fetch for ISIN $isin (${attempts + 1})');
    }
  }
  return {}; // Return empty if all retries fail, though the rethrow will typically handle failure
}

/// Fetches the BTPs with their price histories and creates a daily value map from the earliest BTP date to today.
Future<Map<DateTime, double>> createPortfolioValueGraph(
    [TimeWindow span = TimeWindow.oneMonth]) async {
  List<Map<String, dynamic>> myBTPs;
  try {
    myBTPs = await fetchMyBTPHistories(span);
  } catch (e) {
    print("Error fetching BTP histories: $e");
    return {};
  }

  // Determine the earliest date from BTP purchases
  DateTime earliestDate = DateTime.now();
  for (var btp in myBTPs) {
    for (var entry in btp['priceHistory']['series']) {
      DateTime entryDate = DateTime.parse(entry['timestamp']);
      if (entryDate.isBefore(earliestDate)) {
        earliestDate = entryDate;
      }
    }
  }
  // print earliestDate
  print("Earliest date: $earliestDate");
  double msInner = 0.0;
  DateTime now = DateTime.now();

  // Calculate portfolio value for each day from earliest date to today
  Map<DateTime, double> valueByDate = {};
  // map of isin to last index
  Map<String, int> isinToIndex = {};
  DateTime currentDate = DateTime.now();
  for (DateTime date = earliestDate;
      date.isBefore(currentDate);
      date = date.add(const Duration(days: 1))) {
    double totalValue = 0.0;
    for (var btp in myBTPs) {
      if (btp['buyDate'] != null && btp['buyDate'].isBefore(date)) {
        DateTime now2 = DateTime.now();
        var priceAndIndex =
            _getBTPValueAtDate(btp, date, isinToIndex[btp['isin']] ?? 0);
        var valueAtDate = priceAndIndex[0];
        if (valueAtDate == null) {
          continue;
        }
        isinToIndex[btp['isin']] = priceAndIndex[1];
        msInner += DateTime.now().difference(now2).inMilliseconds;
        totalValue += (valueAtDate * btp['investment'] ?? 0);
        // print("BTP ${btp['isin']} value at $date: $valueAtDate");
      } else {
        print("BTP ${btp['isin']} was bought after $date");
      }
    }
    // String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    valueByDate[date] = totalValue;
  }

  // print difference in time
  print(
      "Time taken: ${DateTime.now().difference(now).inMilliseconds / 1000} seconds");
  print("Inner loop time: ${msInner / 1000} seconds");

  return valueByDate;
}

/// Finds the closest historical price to the target date for a single BTP and calculates its value.
List _getBTPValueAtDate(Map<String, dynamic> btp, DateTime targetDate,
    [int start = 0]) {

  if (btp['priceHistory'] == null) {
    print("No price history available for ISIN ${btp['isin']}");
    return [null, null];
  }

  var series = btp['priceHistory']['series'];
  int limit = btp['priceHistory']['series'].length;
  int i;
  DateTime entryDate;
  for (i = start; i < limit; i++) {
    entryDate = DateTime.parse(series[i]['timestamp']);
    if (entryDate.isAfter(targetDate) &&
        !entryDate.isAtSameMomentAs(targetDate)) {
      if (i == 0) {
        print(
            "No historical data available for ISIN ${btp['isin']} at $targetDate");
        return [null, null];
      }
      return [series[i - 1]['close'], i - 1];  // Return the closest historical price and its index
    }
  }
  return [null, null];
}
