import 'package:hive/hive.dart';

part 'fav_db_model.g.dart';

@HiveType(typeId: 6)
class FavoritesDb extends HiveObject{
 
  @HiveField(0)
  int songIds;
  FavoritesDb({ required this.songIds});

}
