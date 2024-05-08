import 'package:hive/hive.dart';

part 'hivemodels.g.dart';

@HiveType(typeId: 0)
class BTP extends HiveObject {
  @HiveField(0)
  final String isin;
  @HiveField(1)
  final String name;
  @HiveField(2)
  late double value;
  @HiveField(3)
  late double cedola;
  @HiveField(4)
  late DateTime expirationDate;

  BTP.fromData(this.isin, this.name, String value, String cedola,
      String expirationDate) {
    value = value.replaceAll(',', '.');
    cedola = cedola.replaceAll(',', '.');
    this.value = double.tryParse(value) ?? 0.0;
    this.cedola = double.tryParse(cedola) ?? 0.0;
    var date = expirationDate.split('/');
    this.expirationDate = DateTime(int.parse(date[2]), int.parse(date[1]),
        int.parse(date[0]), 0, 0, 0, 0, 0);
  }
  BTP(
      {required this.isin,
      required this.name,
      required this.value,
      required this.cedola,
      required this.expirationDate});
}

@HiveType(typeId: 1)
class MyBTP extends HiveObject {
  @HiveField(0)
  late int investment;
  @HiveField(1)
  late DateTime buyDate;
  @HiveField(2)
  late double buyPrice;
  @HiveField(3)
  late String isin;

  MyBTP.fromData(this.investment, String buyDate, String buyPrice, this.isin) {
    var date = buyDate.split('/');
    this.buyDate = DateTime(int.parse(date[2]), int.parse(date[1]),
        int.parse(date[0]), 0, 0, 0, 0, 0);
    this.buyPrice = double.tryParse(buyPrice) ?? 0.0;
  }
  MyBTP(
      {required this.investment,
      required this.buyDate,
      required this.buyPrice,
      required this.isin});
}
