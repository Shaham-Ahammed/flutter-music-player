// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lazits/Db_Model/db_model.dart';
import 'package:lazits/Db_Model/playlist_model.dart';
import 'package:lazits/Db_function/db_function.dart';
import 'package:lazits/Reusable_widgets/add_to_playlist_alert.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/details_alert.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';
import 'package:lazits/Reusable_widgets/screen_widgets.dart';
import 'package:lazits/Reusable_widgets/share_fucntion.dart';
import 'package:lazits/provider/song_modal_provider.dart';
import 'package:lazits/screens/all_songs_screen.dart';
import 'package:lazits/screens/music_player.dart';
import 'package:lazits/screens/playlist_all_songs.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class OpenPlaylist extends StatefulWidget {
  String playlistName;
  PlaylistDbModel playlistModel;
  OpenPlaylist(
      {required this.playlistName, required this.playlistModel, Key? key})
      : super(key: key);

  @override
  State<OpenPlaylist> createState() => _OpenPlaylistState();
}

class _OpenPlaylistState extends State<OpenPlaylist> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: bgTheme()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: Padding(
          padding:
             screenPadding(context),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  screenHeader(widget.playlistName, context, greyColor),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => AllSongsPlaylist(
                                    playlistModel: widget.playlistModel,
                                  )))
                          .then((value) {
                        setState(() {});
                      });
                    },
                    child: Icon(
                      Icons.add,
                      size: mediaqueryHeight(0.038,  context),
                      color: greyColor,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              FutureBuilder<List<Song>>(
                future: playlistSongs(playslist: widget.playlistModel),
                builder: (context, items) {
                  if (items.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (items.data!.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          "No songs added to playlist",
                          style: TextStyle(
                            fontFamily: "FiraSans",
                            color: greyColor2,
                            fontSize:  mediaqueryWidth(0.045, context),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ListTile(
                                onTap: () {
                                  context
                                      .read<SongModalProvider>()
                                      .setId(items.data![index].songid);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MusicPlayer(
                                            audioPlayer: audioPlayer,
                                            songModel: items.data!,
                                            index: index,
                                            fromFavScreen: false,
                                          )));
                                },
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                   height:  mediaqueryWidth(0.14, context),
                                      width:  mediaqueryWidth(0.16, context),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: const Color.fromARGB(
                                        255, 103, 103, 103),
                                  ),
                                  child: QueryArtworkWidget(
                                    id: items.data![index].songid,
                                    type: ArtworkType.AUDIO,
                                    nullArtworkWidget:  Icon(
                                      Icons.graphic_eq,
                                      size:  mediaqueryWidth(0.070, context),
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                                title: myText(
                                    items.data![index].title,  mediaqueryWidth(0.049, context), Colors.white),
                                trailing: PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  color: grey,
                                  itemBuilder: (context) => [
                                    PopupMenuItem<String>(
                                      value: 'playlist',
                                      child: myText(
                                          "Remove from playlist",  mediaqueryWidth(0.045, context), black),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'favorites',
                                      child:
                                          myText("Add to favorites",  mediaqueryWidth(0.045, context), black),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'share',
                                      child:
                                          myText("Share",  mediaqueryWidth(0.045, context), black),
                                    ),
                                    PopupMenuItem(
                                      value: "details",
                                      child: myText("Details",  mediaqueryWidth(0.045, context), black),
                                    )
                                  ],
                                  onSelected: (value) async {
                                    switch (value) {
                                      case 'playlist':
                                        removeSongsFromPlaylist(
                                            songid: items.data![index].songid,
                                            playlist: widget.playlistModel);

                                        checkSongOnPlaylist(
                                            playlist: widget.playlistModel);
                                        setState(() {});
                                        break;
                                      case 'favorites':
                                        addSongToFav(
                                            songId: items.data![index].songid);

                                        addToFavoritesAlert(context);
                                        break;
                                      case 'share':
                                      await  shareSong(items.data![index]);
                                        break;

                                      case 'details':
                                        detailsAlert(
                                            context: context,
                                            path: items.data![index].path,
                                            artist: items.data![index].artist,
                                            title: items.data![index].title);
                                        break;
                                    }
                                  },
                                  icon: FaIcon(FontAwesomeIcons.ellipsis,
                                      color: greyColor2),
                                ),
                                subtitle: myText(
                                    items.data![index].artist.toString(),
                                      mediaqueryWidth(0.039, context),
                                    const Color.fromARGB(255, 145, 145, 145)),
                              ),
                             screenDivider(context),
                            ],
                          );
                        },
                        itemCount: items.data!.length,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        )),
      ),
    );
  }
}
