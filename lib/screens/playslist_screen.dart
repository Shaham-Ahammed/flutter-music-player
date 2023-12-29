import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lazits/Db_Model/playlist_model.dart';
import 'package:lazits/Db_function/db_function.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';
import 'package:lazits/screens/favorites_screen.dart';
import 'package:lazits/screens/most_played.dart';
import 'package:lazits/screens/open_playlist.dart';
import 'package:lazits/screens/open_recordings.dart';
import 'package:lazits/screens/playlist_all_songs.dart';
import 'package:lazits/screens/recently_played_screen.dart';

class Playlist extends StatefulWidget {
  const Playlist({Key? key}) : super(key: key);

  @override
  PlaylistState createState() => PlaylistState();
}

class PlaylistState extends State<Playlist> {
  List<String> playlists = [
    "Recently played",
    "Most played",
    "Favorites",
    "Recordings"
  ];
  TextEditingController playlistNameController = TextEditingController();
  String newPlaylistName = "";

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
            padding:
                const EdgeInsets.only(bottom: 10, left: 20, right: 20, top: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    myText("Playlists", mediaqueryHeight(0.030, context),
                        greyColor),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        size: mediaqueryHeight(0.032, context),
                      ),
                      onPressed: () {
                        checkplaylistNames();

                        alertDialogue(context: context);
                      },
                      color: greyColor,
                    ),
                  ],
                ),
                SizedBox(
                  height: mediaqueryHeight(0.01, context),
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

                        allPlaylists.addAll(
                            snapshot.data!.map((playlist) => playlist.name));
                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: mediaqueryHeight(0.022, context),
                            mainAxisSpacing: mediaqueryHeight(0.025, context),
                          ),
                          itemCount: allPlaylists.length,
                          itemBuilder: (BuildContext context, int index) {
                            PlaylistDbModel? currentPlaylist;
                            if (index < playlists.length) {
                              currentPlaylist = null;
                            } else {
                              int playlistIndex = index - playlists.length;
                              if (playlistIndex < snapshot.data!.length) {
                                currentPlaylist = snapshot.data![playlistIndex];
                              } else {
                                currentPlaylist = null;
                              }
                            }
                            return buildContainer(
                                allPlaylists[index],
                                index < playlists.length,
                                index,
                                currentPlaylist);
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildContainer(String title, bool isInitialPlaylist, int index,
      PlaylistDbModel? functPlaylist) {
    return InkWell(
      onTap: () {
        if (title == "Favorites") {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => const Favorites(
                        fromPlaylist: true,
                      )))
              .then((value) {
            setState(() {});
          });
        } else if (title == "Recently played") {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => const RecentlyPlayedScreen()))
              .then((value) {
            setState(() {});
          });
        } else if (title == "Most played") {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => const MostPlayedScreen()))
              .then((value) {
            setState(() {});
          });
        } else if (title == 'Recordings') {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const OpenRecordings()));
        } else {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => OpenPlaylist(
                        playlistName: title,
                        playlistModel: functPlaylist!,
                      )))
              .then((value) {
            setState(() {});
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF828282),
              const Color(0xFFDDDDDD).withOpacity(0)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Icon(
                    isInitialPlaylist
                        ? getIconForPlaylist(title)
                        : Icons.library_music,
                    size: mediaqueryHeight(0.045, context),
                    color: const Color(0xFF1D1E1E),
                  ),
                ),
                SizedBox(height: mediaqueryHeight(0.012, context)),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily:"FiraSans",
                    color: greyColor2,
                    fontSize: mediaqueryHeight(0.021, context),
                  ),
                ),
              ],
            ),
            if (!isInitialPlaylist)
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Colors.grey,
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'Add',
                      height: mediaqueryWidth(0.1, context),
                      child: myText(
                          'Add', mediaqueryWidth(0.046, context), Colors.black),
                    ),
                    PopupMenuItem<String>(
                      value: 'Rename',
                      height: mediaqueryWidth(0.1, context),
                      child: myText('Rename', mediaqueryWidth(0.046, context),
                          Colors.black),
                    ),
                    PopupMenuItem<String>(
                      value: 'Delete',
                      height: mediaqueryWidth(0.1, context),
                      child: myText('Delete', mediaqueryWidth(0.046, context),
                          Colors.black),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'Add':
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AllSongsPlaylist(
                                playlistModel: functPlaylist!)));
                        break;
                      case 'Rename':
                        alertDialogue(
                            context: context,
                            name: title,
                            playlists: functPlaylist);
                        break;
                      case 'Delete':
                        deleteAlert(context: context, index: index - 4);
                        break;
                    }
                  },
                  icon: FaIcon(FontAwesomeIcons.ellipsisVertical,
                      size: mediaqueryWidth(0.058, context),
                      color: const Color.fromARGB(255, 193, 193, 193)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData getIconForPlaylist(String playlistTitle) {
    if (playlistTitle == "Recently played") {
      return CommunityMaterialIcons.music_note_sixteenth;
    } else if (playlistTitle == "Most played") {
      return FontAwesomeIcons.music;
    } else if (playlistTitle == "Favorites") {
      return Icons.favorite;
    } else if (playlistTitle == "Recordings") {
      return Icons.mic;
    } else {
      return Icons.folder;
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  alertDialogue(
      {required BuildContext context,
      String? name,
      PlaylistDbModel? playlists}) {
    showDialog(
      context: context,
      builder: (ctx2) {
        String newPlaylistName = name ?? "";
        playlistNameController.text = newPlaylistName;
        return Form(
          key: _formKey,
          child: AlertDialog(
            backgroundColor: greyColor2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Center(
              child: myText("Create Playlist", mediaqueryWidth(0.049, context),
                  Colors.black),
            ),
            content: TextFormField(
              controller: playlistNameController,
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
                } else if (trimmedValue == "") {
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
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Color(0xFF153438)),
                      ),
                      onPressed: () {
                        playlistNameController.clear();
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontFamily:"FiraSans",
                            color: Colors.white,
                            fontSize: mediaqueryWidth(0.046, context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Color(0xFF153438)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (name != null) {
                            renamePlaylist(
                              playlist: playlists!,
                              newName: newPlaylistName,
                            );
                          } else {
                            addPlaylist(name: newPlaylistName, songId: []);
                          }

                          Navigator.of(context).pop();
                          playlistNameController.clear();
                          setState(() {});
                        } else {
                          return;
                        }
                      },
                      child: Center(
                        child: Text(
                          name == null ? "Create" : "Update",
                          style: TextStyle(
                            fontFamily: "FiraSans",
                            color: Colors.white,
                            fontSize: mediaqueryWidth(0.046, context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
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

  deleteAlert({required BuildContext context, required int index}) {
    showDialog(
      context: context,
      builder: (ctx2) {
        return AlertDialog(
          backgroundColor: greyColor2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Center(
            child: myText("Delete playlist ?", mediaqueryWidth(0.052, context),
                Colors.black),
          ),
          contentPadding: EdgeInsets.only(
              left: mediaqueryWidth(0.05, context),
              right: mediaqueryWidth(0.05, context)),
          actions: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.max,
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
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontFamily: "FiraSans",
                          color: Colors.white,
                          fontSize: mediaqueryWidth(0.046, context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red),
                    ),
                    onPressed: () {
                      deletePlayList(index);
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    child: Center(
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          fontFamily:"FiraSans",
                          color: Colors.white,
                          fontSize: mediaqueryWidth(0.046, context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
