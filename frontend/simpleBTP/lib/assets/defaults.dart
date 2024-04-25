export 'defaults.dart';

final Map<String, dynamic> defaultExploreFilters = {
  'minValue': null, // double
  'maxValue': null, // double
  'minCedola': null, // double
  'maxCedola': null, // double
  'minExpiration': null, // DateTime
  'maxExpiration': null, // DateTime
};

final Map<String, dynamic> defaultExploreOrdering = {
  'orderBy': 'value', // value, cedola, expirationDate
  'order': 'desc', // asc, desc
};
