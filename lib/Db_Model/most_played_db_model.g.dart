// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'most_played_db_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MostPlayedAdapter extends TypeAdapter<MostPlayed> {
  @override
  final int typeId = 5;

  @override
  MostPlayed read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MostPlayed(
      songIds: fields[0] as int,
      count: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MostPlayed obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.songIds)
      ..writeByte(1)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MostPlayedAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
