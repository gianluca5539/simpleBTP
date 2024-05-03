// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hivemodels.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BTPAdapter extends TypeAdapter<BTP> {
  @override
  final int typeId = 0;

  @override
  BTP read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BTP(
      isin: fields[0] as String,
      name: fields[1] as String,
      value: fields[2] as double,
      cedola: fields[3] as double,
      expirationDate: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BTP obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.isin)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.cedola)
      ..writeByte(4)
      ..write(obj.expirationDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BTPAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MyBTPAdapter extends TypeAdapter<MyBTP> {
  @override
  final int typeId = 1;

  @override
  MyBTP read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MyBTP(
      investment: fields[0] as int,
      buyDate: fields[1] as DateTime,
      buyPrice: fields[2] as double,
      isin: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MyBTP obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.investment)
      ..writeByte(1)
      ..write(obj.buyDate)
      ..writeByte(2)
      ..write(obj.buyPrice)
      ..writeByte(3)
      ..write(obj.isin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyBTPAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
