// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:lazits/Db_Model/playlist_model.dart';
import 'package:lazits/Db_function/db_function.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';
import 'package:lazits/Reusable_widgets/screen_widgets.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AllSongsPlaylist extends StatefulWidget {
  final PlaylistDbModel playlistModel;
  AllSongsPlaylist({Key? key, required this.playlistModel}) : super(key: key);

  @override
  State<AllSongsPlaylist> createState() => _AllSongsPlaylistState();
}

class _AllSongsPlaylistState extends State<AllSongsPlaylist> {
  @override
  void initState() {
    checkSongOnPlaylist(playlist: widget.playlistModel);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: bgTheme(),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: screenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                screenHeader("Select tracks", context, greyColor),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Expanded(
                  child: FutureBuilder(
                    future: music(),
                    builder: (context, items) {
                      if (items.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (items.data!.isEmpty) {
                        return myText("No Songs Found",
                            mediaqueryWidth(0.045, context), Colors.white);
                      } else {
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: mediaqueryWidth(0.14, context),
                                    width: mediaqueryWidth(0.16, context),
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
                                        size:   mediaqueryWidth(0.070, context),
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                  title: myText(items.data![index].title,    mediaqueryWidth(0.049, context),
                                      Colors.white),
                                  trailing: songsinPlylist
                                          .contains(items.data![index].songid)
                                      ? IconButton(
                                          onPressed: () {
                                            removeSongsFromPlaylist(
                                                songid:
                                                    items.data![index].songid,
                                                playlist: widget.playlistModel);

                                            checkSongOnPlaylist(
                                                playlist: widget.playlistModel);
                                            setState(() {});
                                          },
                                          icon:  Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: mediaqueryHeight(0.03, context),
                                          ))
                                      : IconButton(
                                          onPressed: () {
                                            addSongsToPlaylist(
                                                songid:
                                                    items.data![index].songid,
                                                playlist: widget.playlistModel);

                                            checkSongOnPlaylist(
                                                playlist: widget.playlistModel);
                                            setState(() {});
                                          },
                                          icon:  Icon(
                                            Icons.add,
                                            size: mediaqueryHeight(0.03, context),
                                            color: Colors.white,
                                          ),
                                        ),
                                  subtitle: myText(
                                    items.data![index].artist.toString(),
                                     mediaqueryWidth(0.039, context),
                                    const Color.fromARGB(255, 145, 145, 145),
                                  ),
                                ),
                               screenDivider(context)
                              ],
                            );
                          },
                          itemCount: items.data!.length,
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
