export 'defaults.dart';

final Map<String, dynamic> defaultExploreFilters = {
  'minValue': null, // double
  'maxValue': null, // double
  'minCedola': null, // double
  'maxCedola': null, // double
  'minExpirationDate': null, // DateTime
  'maxExpirationDate': null, // DateTime
};

final Map<String, dynamic> defaultExploreOrdering = {
  'orderBy': 'value', // value, cedola, expirationDate
  'order': 'desc', // asc, desc
};
