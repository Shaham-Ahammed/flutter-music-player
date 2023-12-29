import 'package:hive/hive.dart';

part 'most_played_db_model.g.dart';

@HiveType(typeId: 5)
class MostPlayed extends HiveObject {
  @HiveField(0)
  int songIds;

  @HiveField(1)
  int count;
  MostPlayed({required this.songIds,required this.count});
}
