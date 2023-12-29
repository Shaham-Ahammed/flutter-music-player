// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:lazits/Db_Model/db_model.dart';

import 'package:lazits/Db_function/db_function.dart';
import 'package:lazits/Reusable_widgets/add_to_playlist_alert.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';
import 'package:lazits/Reusable_widgets/screen_widgets.dart';

class AddToPlayslist extends StatefulWidget {
  final Song song;
  final bool fromAllSongsScreen;
  const AddToPlayslist({
    Key? key,
    required this.song,
    required this.fromAllSongsScreen,
  }) : super(key: key);

  @override
  State<AddToPlayslist> createState() => _AddToPlayslistState();
}

class _AddToPlayslistState extends State<AddToPlayslist> {
  List<String> playlists = ["Favorites"];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
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
                screenHeader("Add to", context,Colors.white),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                GestureDetector(
                  onTap: () {
                    checkplaylistNames();
                    alertDialogue(context);
                  },
                  child: Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.all(mediaqueryHeight(0.015, context)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: greyColor2,
                        ),
                        child: const Icon(FontAwesomeIcons.plus),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.07,
                      ),
                      Text(
                        "Create playlist",
                        style: TextStyle(
                          fontFamily:"FiraSans",
                          color: Colors.white,
                          fontSize: mediaqueryHeight(0.025, context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  indent: mediaqueryHeight(0.0935, context),
                  thickness: 1,
                  color: const Color.fromARGB(255, 103, 103, 103),
                ),
                SizedBox(
                  height: mediaqueryHeight(0.006, context),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: getFromPlaylist(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<String> allPlaylists = List.from(playlists);
                        if (snapshot.data != null) {
                          allPlaylists.addAll(
                              snapshot.data!.map((playlist) => playlist.name));
                        }
                        if (!widget.fromAllSongsScreen) {
                          allPlaylists.remove("Favorites");
                        }

                        return ListView.builder(
                          itemCount: allPlaylists.length,
                          itemBuilder: ((context, index) {
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (widget.fromAllSongsScreen) {
                                      if (allPlaylists[index] == "Favorites") {
                                        addSongToFav(
                                            songId: widget.song.songid);
                                        addToFavoritesAlert(context);
                                      } else {
                                        final song = widget.song;
                                        await addSongsToPlaylist(
                                            songid: song.songid.toInt(),
                                            playlist:
                                                snapshot.data![index - 1]);

                                        addToPlaylistAlert(
                                            context: context,
                                            playlistName:
                                                snapshot.data![index - 1].name);
                                      }
                                    } else {
                                      await addSongsToPlaylist(
                                          songid: widget.song.songid.toInt(),
                                          playlist: snapshot.data![index]);
                                      addToPlaylistAlert(
                                          context: context,
                                          playlistName:
                                              snapshot.data![index].name);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(
                                            (mediaqueryHeight(0.015, context))),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: greyColor2,
                                        ),
                                        child: Icon(
                                          getIconForPlaylist(
                                              allPlaylists[index]),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.07,
                                      ),
                                      Text(
                                        allPlaylists[index],
                                        style: TextStyle(
                                          fontFamily:
                                             "FiraSans",
                                          color: Colors.white,
                                          fontSize:
                                              mediaqueryHeight(0.025, context),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  indent: mediaqueryHeight(0.0935, context),
                                  thickness: 1,
                                  color:
                                      const Color.fromARGB(255, 103, 103, 103),
                                ),
                                SizedBox(
                                  height: mediaqueryHeight(0.006, context),
                                )
                              ],
                            );
                          }),
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

  IconData getIconForPlaylist(String playlist) {
    if (playlist == "Favorites") {
      return Icons.favorite;
    } else {
      return Icons.library_music;
    }
  }

  alertDialogue(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx2) {
        String newPlaylistName = "";

        return Form(
          key: _formKey,
          child: AlertDialog(
            backgroundColor: greyColor2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Center(
              child: myText("Create Playlist", mediaqueryHeight(0.024, context),
                  Colors.black),
            ),
            content: TextFormField(
              controller: nameController,
              onChanged: (value) {
                newPlaylistName = value.trim();
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                String trimmedValue = value!.trim();
                if (trimmedValue == 'Recently played' ||
                    trimmedValue == 'Most played' ||
                    trimmedValue == 'Favorites' ||
                    trimmedValue == 'Recordings' ||
                    playlistNames.contains(trimmedValue)) {
                  return "Playlist already exists";
                } else if (trimmedValue.isEmpty) {
                  return "Please enter a name";
                } else {
                  return null;
                }
              },
              maxLength: 18,
              decoration: const InputDecoration(
                hintText: "playlist name",
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black45),
                ),
              ),
            ),
            contentPadding: EdgeInsets.only(
                left: mediaqueryWidth(0.05, context),
                right: mediaqueryWidth(0.05, context)),
            actions: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Color(0xFF153438)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: myText("Cancel", mediaqueryWidth(0.048, context), Colors.white),
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Color(0xFF153438)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          addPlaylist(name: newPlaylistName, songId: []);
                          setState(() {});
                          Navigator.of(context).pop();
                          nameController.clear();
                        }
                      },
                      child: myText("Create", mediaqueryWidth(0.048, context), Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
