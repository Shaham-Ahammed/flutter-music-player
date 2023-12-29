import 'package:hive/hive.dart';
part 'db_model.g.dart';

@HiveType(typeId: 1)
class Song {
  @HiveField(0)
  String title;
  @HiveField(1)
  int songid;
  @HiveField(2)
  String uri;
  @HiveField(3)
  String artist;
  @HiveField(4)
  String path;

  Song(
      {required this.title,
      required this.songid,
      required this.uri,
      required this.artist,
      required this.path});
}
