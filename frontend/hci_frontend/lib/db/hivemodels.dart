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

  BTP(this.isin, this.name, String value, String cedola,
      String expirationDate) {
    value = value.replaceAll(',', '.');
    cedola = cedola.replaceAll(',', '.');
    this.value = double.tryParse(value) ?? 0.0;
    this.cedola = double.tryParse(cedola) ?? 0.0;
    var date = expirationDate.split('/');
    this.expirationDate = DateTime(int.parse(date[2]), int.parse(date[1]),
        int.parse(date[0]), 0, 0, 0, 0, 0);
  }
}
