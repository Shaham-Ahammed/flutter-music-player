import 'package:flutter/material.dart';
import 'package:lazits/Db_Model/db_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lazits/Db_Model/fav_db_model.dart';
import 'package:lazits/Db_Model/most_played_db_model.dart';
import 'package:lazits/Db_Model/playlist_model.dart';
import 'package:lazits/Db_Model/recently_played_db_model.dart';
import 'package:on_audio_query/on_audio_query.dart';

final _audioQuery = OnAudioQuery();

Future<List<SongModel>> getSongs() async {
  try {
    List<SongModel> song = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    song = song.where((song) => !song.data.contains("WhatsApp Audio")).toList();

    mostPlayedUpdate(songs: song);
    return song;
  } catch (e) {
    debugPrint("Error fetching songs: $e");
    return [];
  }
}

Future<List<Song>> music() async {
  List<Song> songs = [];
  final songDB = await Hive.openBox<Song>('song_db');
  await songDB.clear();
  List<SongModel> allSongs = await getSongs();
  for (SongModel song in allSongs) {
    songDB.add(Song(
        artist: song.artist.toString(),
        songid: song.id.toInt(),
        uri: song.uri.toString(),
        title: song.title,
        path: song.data));
  }
  for (int i = 0; i < songDB.length; i++) {
    Song a = songDB.get(i)!;
    songs.add(a);
  }

  debugPrint("${songDB.length}");
  return songs;
}

//Recorder

Future<List<Song>> recordingsList() async {
  List<Song> allSongs = await music();
  List<Song> records = [];
  for (int i = 0; i < allSongs.length; i++) {
    if (allSongs[i].path.contains("lazit recordings")) {
      records.add(allSongs[i]);
    }
  }
  return records;
}

//favourites

addSongToFav({required int songId, String? title}) async {
  final favBox = await Hive.openBox<FavoritesDb>('favorites');
  List<FavoritesDb> fd = favBox.values.toList();

  bool songAlreadyExists = fd.any((fav) => fav.songIds == (songId));

  if (!songAlreadyExists) {
    favBox.add(FavoritesDb(songIds: songId));
    debugPrint("Song added to fav");
  } else {
    debugPrint("Song is already in fav");
  }
}

removeSongFromFav({required int songId}) async {
  final favBox = await Hive.openBox<FavoritesDb>('favorites');
  List<FavoritesDb> fd = favBox.values.toList();

  for (int i = 0; i < fd.length; i++) {
    if (fd[i].songIds == songId) {
      favBox.deleteAt(i);
      debugPrint("song removed from fav");
    }
  }
}

Future<List<Song>> favSongList() async {
  final favBox = await Hive.openBox<FavoritesDb>('favorites');
  List<Song> allSongs = await music();
  List<FavoritesDb> fav = favBox.values.toList();
  List<Song> favRet = [];
  for (int i = 0; i < fav.length; i++) {
    for (int j = 0; j < allSongs.length; j++) {
      if (fav[i].songIds == allSongs[j].songid) {
        favRet.add(allSongs[j]);
      }
    }
  }
  return favRet;
}

List<int> favoriteSongIds = [];

checkIsFav() async {
  favoriteSongIds.clear();
  final favBox = await Hive.openBox<FavoritesDb>('favorites');
  List<FavoritesDb> favList = favBox.values.toList();
  for (int i = 0; i < favList.length; i++) {
    favoriteSongIds.add(favList[i].songIds);
  }
}

//playlist
addPlaylist({required String name, required List<int> songId}) async {
  final playListDb = await Hive.openBox<PlaylistDbModel>('playlist_db');
  playListDb.add(PlaylistDbModel(name: name, songIds: songId));

  debugPrint("sham${playListDb.length}");
}

Future<List<PlaylistDbModel>> getFromPlaylist() async {
  List<PlaylistDbModel> pldb = [];
  final playListDb = await Hive.openBox<PlaylistDbModel>('playlist_db');
  pldb = playListDb.values.toList();
  return pldb;
}

deletePlayList(int index) async {
  final playListDb = await Hive.openBox<PlaylistDbModel>('playlist_db');
  if (index >= 0 && index < playListDb.length) {
    playListDb.deleteAt(index);
    debugPrint("Playlist deleted at index: $index");
    debugPrint("sham${playListDb.length}");
  } else {
    debugPrint("Invalid index for playlist deletion");
  }
}

renamePlaylist(
    {required PlaylistDbModel playlist, required String newName}) async {
  final playListDb = await Hive.openBox<PlaylistDbModel>('playlist_db');

  final storedPlaylist = playListDb.get(playlist.key);

  if (storedPlaylist != null) {
    storedPlaylist.name = newName;
    playListDb.put(playlist.key, storedPlaylist);
  }
}

addSongsToPlaylist(
    {required int songid, required PlaylistDbModel playlist}) async {
  final playListDb = await Hive.openBox<PlaylistDbModel>('playlist_db');
  final pl = playListDb.get(playlist.key);
  if (!pl!.songIds.contains(songid)) {
    pl.songIds.add(songid);
    playListDb.put(playlist.key, pl);
    debugPrint("$songid added");
  } else {
    debugPrint("song already present in playlist");
  }
}

List<int> songsinPlylist = [];

checkSongOnPlaylist({required PlaylistDbModel playlist}) async {
  final playListDb = await Hive.openBox<PlaylistDbModel>('playlist_db');
  final pl = playListDb.get(playlist.key);
  songsinPlylist = pl!.songIds;
}

List<String> playlistNames = [];

checkplaylistNames() async {
  playlistNames.clear();
  final playListBox = await Hive.openBox<PlaylistDbModel>('playlist_db');
  for (int i = 0; i < playListBox.length; i++) {
    final playlist = playListBox.getAt(i);
    if (playlist != null) {
      playlistNames.add(playlist.name);
      debugPrint("playlist name $i - ${playlist.name}");
    }
  }
  await playListBox.close();
}

removeSongsFromPlaylist(
    {required int songid, required PlaylistDbModel playlist}) async {
  final playListDb = await Hive.openBox<PlaylistDbModel>('playlist_db');
  final pl = playListDb.get(playlist.key);
  pl!.songIds.remove(songid);
  playListDb.put(playlist.key, pl);
  debugPrint("$songid removed");
}

Future<List<Song>> playlistSongs({required PlaylistDbModel playslist}) async {
  final playListDb = await Hive.openBox<PlaylistDbModel>('playlist_db');
  PlaylistDbModel? s = playListDb.get(playslist.key);
  List<int> plSongs = s!.songIds;
  List<Song> allSongs = await music();
  List<Song> result = [];
  for (int i = 0; i < allSongs.length; i++) {
    for (int j = 0; j < plSongs.length; j++) {
      if (allSongs[i].songid == plSongs[j]) {
        result.add(Song(
            title: allSongs[i].title,
            songid: allSongs[i].songid,
            uri: allSongs[i].uri,
            artist: allSongs[i].artist,
            path: allSongs[i].path));
      }
    }
  }
  return result;
}

//recently played

void addSongToRecentlyPlayed(int songId) async {
  final recentlyPlayedBox = await Hive.openBox<RecentlyPlayed>('recents');
  List<RecentlyPlayed> songs = recentlyPlayedBox.values.toList();
  for (int i = 0; i < songs.length; i++) {
    if (songs[i].songIds == songId) {
      recentlyPlayedBox.delete(songs[i].key);
      break;
    }
  }
  recentlyPlayedBox.add(RecentlyPlayed(songIds: songId));
}

Future<List<Song>> recentlyPlayedSongs() async {
  final recentlyPlayedBox = await Hive.openBox<RecentlyPlayed>('recents');
  List<RecentlyPlayed> songs = recentlyPlayedBox.values.toList();
  List<Song> allSongs = await music();
  List<Song> recents = [];
  for (int i = 0; i < songs.length; i++) {
    for (int j = 0; j < allSongs.length; j++) {
      if (songs[i].songIds == allSongs[j].songid) {
        recents.add(allSongs[j]);
      }
    }
  }

  return recents.reversed.toList();
}

//mostly played

mostPlayedUpdate({required List<SongModel> songs}) async {
  final songDb = await Hive.openBox<MostPlayed>("most_played");
  if (songDb.isEmpty) {
    debugPrint("most played empty");
    for (SongModel song in songs) {
      songDb.add(MostPlayed(songIds: song.id.toInt(), count: 0));
    }
  } else {
    debugPrint("most played not empty");
    for (SongModel song in songs) {
      if (!songDb.values.any((element) => element.songIds == song.id.toInt())) {
        songDb.add(MostPlayed(songIds: song.id.toInt(), count: 0));
      }
    }
  }
}

addSongToMostPlayed(int songId) async {
  final mostPlayed = await Hive.openBox<MostPlayed>('most_played');
  List<MostPlayed> songs = mostPlayed.values.toList();
  for (int i = 0; i < songs.length; i++) {
    if (songs[i].songIds == songId) {
      final plSong = mostPlayed.get(songs[i].key);
      plSong!.count++;
      mostPlayed.put(songs[i].key, plSong);
      debugPrint("addeddddd");
      break;
    }
  }
}

Future<List<Song>> mostPlayedSongs() async {
  final mostPlayed = await Hive.openBox<MostPlayed>('most_played');
  List<MostPlayed> songs = mostPlayed.values.toList();
  List<Song> allSongs = await music();
  List<MostPlayed> most = [];
  List<Song> finalList = [];
  for (int i = 0; i < songs.length; i++) {
    if (songs[i].count > 0) {
      most.add(songs[i]);
    }
  }
  most.sort((a, b) => b.count.compareTo(a.count));
  List<MostPlayed> mostOrder = List.from(most);
  for (int i = 0; i < mostOrder.length; i++) {
    for (int j = 0; j < allSongs.length; j++) {
      if (mostOrder[i].songIds == allSongs[j].songid) {
        finalList.add(allSongs[j]);
      }
    }
  }
  return finalList;
}
