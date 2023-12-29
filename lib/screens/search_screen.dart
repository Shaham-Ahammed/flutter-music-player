// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:lazits/Db_Model/db_model.dart';
import 'package:lazits/Db_function/db_function.dart';
import 'package:lazits/Reusable_widgets/add_to_playlist_alert.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/details_alert.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:lazits/Reusable_widgets/logo.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';
import 'package:lazits/Reusable_widgets/screen_widgets.dart';
import 'package:lazits/Reusable_widgets/share_fucntion.dart';
import 'package:lazits/provider/song_modal_provider.dart';
import 'package:lazits/screens/add_to_playslist.dart';
import 'package:lazits/screens/all_songs_screen.dart';
import 'package:lazits/screens/music_player.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
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
                  Stack(
                    children: [
                       logo1(mediaqueryWidth(0.067, context)),
                        Positioned(
                          child: logo2(mediaqueryWidth(0.067, context)),
                          left: mediaqueryWidth(0.062, context),
                      ),
                    ],
                  ),
                   SizedBox(
                    height: mediaqueryHeight(0.011, context),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: greyColor3),
                    ),
                    child: Padding(
                      padding:  EdgeInsets.symmetric(
                          vertical: mediaqueryHeight(0.016, context), horizontal: mediaqueryHeight(0.02, context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (query) {
                                setState(() {});
                              },
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration.collapsed(
                                hintText: "Search",
                                hintStyle: TextStyle(
                                  fontSize: mediaqueryHeight(0.024,context),
                                  color: Colors.white,
                                  fontFamily: "FiraSans",
                                ),
                              ),
                            ),
                          ),
                           Icon(
                            Icons.search_rounded,
                            size: mediaqueryHeight(0.028, context),
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                 SizedBox(
                    height: mediaqueryHeight(0.006, context),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Song>>(
                      future: music(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              "No songs found",
                              style: TextStyle(
                                fontFamily: "FiraSans",
                                color: greyColor2,
                                fontSize:  mediaqueryWidth(0.045, context),
                              ),
                            ),
                          );
                        } else {
                          List<Song> filteredSongs = snapshot.data!
                              .where((song) => song.title
                                  .toLowerCase()
                                  .contains(
                                      _searchController.text.toLowerCase()))
                              .toList();

                          return RefreshIndicator(
                            onRefresh: () async {
                              setState(() {});
                            },
                            child: ListView.builder(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();

                                        context
                                            .read<SongModalProvider>()
                                            .setId(filteredSongs[index].songid);
                                        await Future.delayed(
                                            const Duration(milliseconds: 250));
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => MusicPlayer(
                                                audioPlayer: audioPlayer,
                                                songModel: filteredSongs,
                                                index: index,
                                                fromFavScreen: false,
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                      contentPadding: EdgeInsets.zero,
                                      leading: Container(
                                         height:  mediaqueryWidth(0.14, context),
                                      width:  mediaqueryWidth(0.16, context),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          color: const Color.fromARGB(
                                              255, 103, 103, 103),
                                        ),
                                        child: QueryArtworkWidget(
                                          id: filteredSongs[index].songid,
                                          type: ArtworkType.AUDIO,
                                          nullArtworkWidget:  Icon(
                                            Icons.graphic_eq,
                                            size:   mediaqueryWidth(0.070, context),
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                                      title: myText(
                                        filteredSongs[index].title,
                                        mediaqueryWidth(0.049, context),
                                        Colors.white,
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        color: grey,
                                        itemBuilder: (context) => [
                                          PopupMenuItem<String>(
                                            value: 'playlist',
                                            child: myText(
                                              "Add to playlist",
                                              mediaqueryWidth(0.045, context),
                                              black,
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'favorites',
                                            child: myText(
                                                "Add to favorites", mediaqueryWidth(0.045, context), black),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'share',
                                            child: myText(
                                              "Share",
                                              mediaqueryWidth(0.045, context),
                                              black,
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: "details",
                                            child: myText("Details", mediaqueryWidth(0.045, context), black),
                                          )
                                        ],
                                        onSelected: (value) async {
                                          switch (value) {
                                            case 'playlist':
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddToPlayslist(
                                                              song: snapshot
                                                                  .data![index],
                                                              fromAllSongsScreen:
                                                                  true)));
                                              break;
                                            case 'favorites':
                                              addSongToFav(
                                                  songId: snapshot
                                                      .data![index].songid);

                                              addToFavoritesAlert(context);
                                              break;
                                            case 'share':
                                              shareSong(snapshot.data![index]);
                                              break;

                                            case 'details':
                                              detailsAlert(
                                                context: context,
                                                path: filteredSongs[index].path,
                                                artist:
                                                    filteredSongs[index].artist,
                                                title:
                                                    filteredSongs[index].title,
                                              );
                                              break;
                                          }
                                        },
                                        icon: FaIcon(FontAwesomeIcons.ellipsis,
                                            color: greyColor2),
                                      ),
                                      subtitle: myText(
                                        filteredSongs[index].artist.toString(),
                                        mediaqueryWidth(0.039, context),
                                        const Color.fromARGB(
                                            255, 145, 145, 145),
                                      ),
                                    ),
                                    screenDivider(context),
                                  ],
                                );
                              },
                              itemCount: filteredSongs.length,
                            ),
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
      ),
    );
  }
}
