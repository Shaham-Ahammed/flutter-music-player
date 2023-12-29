import 'package:hive/hive.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 3)
class PlaylistDbModel extends HiveObject{
  @HiveField(0)
  String name;

  @HiveField(1)
  List<int> songIds;
  PlaylistDbModel({required this.name, required this.songIds});
}
