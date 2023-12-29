import 'package:hive/hive.dart';

part 'recently_played_db_model.g.dart';

@HiveType(typeId: 4)
class RecentlyPlayed extends HiveObject{
 
  @HiveField(0)
  int songIds;
  RecentlyPlayed({ required this.songIds});

}
