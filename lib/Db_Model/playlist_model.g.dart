// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaylistDbModelAdapter extends TypeAdapter<PlaylistDbModel> {
  @override
  final int typeId = 3;

  @override
  PlaylistDbModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaylistDbModel(
      name: fields[0] as String,
      songIds: (fields[1] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, PlaylistDbModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.songIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistDbModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
