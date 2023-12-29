// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fav_db_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoritesDbAdapter extends TypeAdapter<FavoritesDb> {
  @override
  final int typeId = 6;

  @override
  FavoritesDb read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoritesDb(
      songIds: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FavoritesDb obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.songIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritesDbAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
