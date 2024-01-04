// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lazits/Db_Model/db_model.dart';
import 'package:lazits/Db_function/db_function.dart';
import 'package:lazits/Reusable_widgets/add_to_playlist_alert.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/details_alert.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';
import 'package:lazits/Reusable_widgets/screen_widgets.dart';
import 'package:lazits/Reusable_widgets/share_fucntion.dart';
import 'package:lazits/provider/song_modal_provider.dart';
import 'package:lazits/screens/add_to_playslist.dart';
import 'package:lazits/screens/all_songs_screen.dart';
import 'package:lazits/screens/music_player.dart';
import 'package:provider/provider.dart';

class OpenRecordings extends StatefulWidget {
  const OpenRecordings({super.key});

  @override
  State<OpenRecordings> createState() => _OpenRecordingsState();
}

class _OpenRecordingsState extends State<OpenRecordings> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: bgTheme()),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: Padding(
          padding: screenPadding(context),
          child: Column(
            children: [
              screenHeader("Recording", context, greyColor),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Expanded(
                child: FutureBuilder<List<Song>>(
                  future: recordingsList(),
                  builder: (context, items) {
                    if (items.data == null) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (items.data!.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            "no recordings found",
                            style: TextStyle(
                              fontFamily:"FiraSans",
                              color: greyColor2,
                              fontSize: mediaqueryWidth(0.045, context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    context
                                        .read<SongModalProvider>()
                                        .setId(items.data![index].songid);
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => MusicPlayer(
                                                  audioPlayer: audioPlayer,
                                                  songModel: items.data!,
                                                  index: index,
                                                  fromFavScreen: false,
                                                  fromRecords:true
                                                )))
                                        .then((value) {
                                      setState(() {});
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    height: mediaqueryWidth(0.14, context),
                                    width: mediaqueryWidth(0.16, context),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: const Color.fromARGB(
                                          255, 103, 103, 103),
                                    ),
                                    child: Icon(
                                      Icons.mic_none_outlined,
                                      size: mediaqueryWidth(0.070, context),
                                      color: Colors.white54,
                                    ),
                                  ),
                                  title: myText(
                                      items.data![index].title,
                                      mediaqueryWidth(0.049, context),
                                      Colors.white),
                                  trailing: PopupMenuButton<String>(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    color: grey,
                                    itemBuilder: (context) => [
                                      PopupMenuItem<String>(
                                        value: 'playlist',
                                        child: myText(
                                            "Add to playlist",
                                            mediaqueryWidth(0.045, context),
                                            black),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'favorites',
                                        child: myText(
                                            "Add to favorites",
                                            mediaqueryWidth(0.045, context),
                                            black),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'share',
                                        child: myText(
                                            "Share",
                                            mediaqueryWidth(0.045, context),
                                            black),
                                      ),
                                      PopupMenuItem(
                                        value: "details",
                                        child: myText(
                                            "Details",
                                            mediaqueryWidth(0.045, context),
                                            black),
                                      ),
                                      PopupMenuItem(
                                        value: "delete",
                                        child: myText(
                                            "Delete",
                                            mediaqueryWidth(0.045, context),
                                            black),
                                      ),
                                    ],
                                    onSelected: (value) async {
                                      switch (value) {
                                        case 'playlist':
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddToPlayslist(
                                                          song: items
                                                              .data![index],
                                                          fromAllSongsScreen:
                                                              true)));
                                          break;
                                        case 'favorites':
                                          addSongToFav(
                                              songId:
                                                  items.data![index].songid);

                                          addToFavoritesAlert(context);
                                          break;
                                        case 'share':
                                          await shareSong(items.data![index]);
                                          break;

                                        case 'details':
                                          detailsAlert(
                                              context: context,
                                              path: items.data![index].path,
                                              artist: items.data![index].artist,
                                              title: items.data![index].title);
                                          break;
                                        case 'delete':
                                          deleteAlert(
                                              context, items.data![index].path,
                                              () {
                                            setState(() {});
                                          });
                                      }
                                    },
                                    icon: FaIcon(FontAwesomeIcons.ellipsis,
                                        color: greyColor2),
                                  ),
                                 
                                ),
                                screenDivider(context)
                              ],
                            );
                          },
                          itemCount: items.data!.length);
                    }
                  },
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

void deleteAlert(BuildContext context, String path, VoidCallback onDelete) {
  showDialog(
      context: context,
      builder: (ctx2) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: greyColor2,
          title: Center(
            child: Text(
              "Delete recording",
              style: TextStyle(
                fontFamily: "FiraSans",
                color: Colors.black,
                fontSize: mediaqueryWidth(0.053, context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: myText("Cancel   ", mediaqueryWidth(0.053, context),
                        Colors.black)),
                Container(
                  height: mediaqueryHeight(0.026, context),
                  width: 1,
                  color: Colors.black,
                ),
                TextButton(
                    onPressed: () {
                      _deleteRecording(path, context, onDelete);
                    },
                    child: myText("   Delete", mediaqueryWidth(0.053, context),
                        Colors.red))
              ],
            )
          ],
          actionsPadding:
              EdgeInsets.only(bottom: mediaqueryHeight(0.01, context)),
          titlePadding: EdgeInsets.only(
              bottom: mediaqueryHeight(0.01, context),
              top: mediaqueryWidth(0.05, context)),
        );
      });
}

_deleteRecording(String filepath, context, VoidCallback onDelete) async {
  try {
    File file = File(filepath);

    if (await file.exists()) {
      await file.delete();

      print("Deleted: $filepath");
      onDelete();
    } else {
      print("File does not exist: $filepath");
    }

    Navigator.pop(context);
  } catch (e) {
    print("Error deleting file: $e");
  }
}
