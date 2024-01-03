import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lazits/Db_Model/db_model.dart';
import 'package:lazits/Db_Model/fav_db_model.dart';
import 'package:lazits/Db_Model/most_played_db_model.dart';
import 'package:lazits/Db_Model/playlist_model.dart';
import 'package:lazits/Db_Model/recently_played_db_model.dart';
import 'package:lazits/bottom_navigation.dart';
import 'package:lazits/provider/song_modal_provider.dart';
import 'package:lazits/screens/splash_screen.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();

  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(FavoritesDbAdapter());
  Hive.registerAdapter(PlaylistDbModelAdapter());
  Hive.registerAdapter(RecentlyPlayedAdapter());
  Hive.registerAdapter(MostPlayedAdapter());
   await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );


  runApp(
    ChangeNotifierProvider(
      create: (context) => SongModalProvider(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (ctx) => const SplashScreen(),
        "bottomNavigation": (context) => const BottomNavigation(),     
      },
    );
  }
}
