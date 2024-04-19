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
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
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
