// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lazits/Db_Model/db_model.dart';
import 'package:lazits/Db_function/db_function.dart';
import 'package:lazits/Reusable_widgets/add_to_playlist_alert.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/details_alert.dart';
import 'package:lazits/Reusable_widgets/logo.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';
import 'package:lazits/Reusable_widgets/screen_widgets.dart';
import 'package:lazits/Reusable_widgets/share_fucntion.dart';
import 'package:lazits/provider/song_modal_provider.dart';
import 'package:lazits/screens/add_to_playslist.dart';
import 'package:lazits/screens/music_player.dart';
import 'package:lazits/screens/privacy_policy.dart';
import 'package:lazits/screens/terms_and_conditions.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

final audioPlayer = AudioPlayer();

class AllSongs extends StatefulWidget {
  const AllSongs({
    super.key,
  });

  @override
  State<AllSongs> createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
  List<SongModel> smSongs = [];
  @override
  void initState() {
    super.initState();
  }

 
  double sliderValue = 0.36;
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
                    Stack(
                      children: [
                        logo1(mediaqueryWidth(0.067, context)),
                        Positioned(
                          child: logo2(mediaqueryWidth(0.067, context)),
                          left: mediaqueryWidth(0.062, context),
                        ),
                      ],
                    ),
                    IconButton(
                      iconSize: mediaqueryWidth(0.070, context),
                      color: const Color(0xFFB2BDBE),
                      onPressed: () {
                        bottomSheet(context);
                      },
                      icon: const Icon(Icons.settings),
                    )
                  ],
                ),
                 SizedBox(
                  height: mediaqueryHeight(0.01, context),
                ),
                Column(
                  children: [
                    const Divider(
                      thickness: 1,
                      color: Color.fromARGB(255, 103, 103, 103),
                    ),
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 3,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: FutureBuilder<List<Song>>(
                    future: music(),
                    builder: (context, items) {
                      if (items.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (items.data!.isEmpty) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              "No Songs Found",
                              style: TextStyle(
                                fontFamily:"FiraSans",
                                color: greyColor2,
                                fontSize:  mediaqueryWidth(0.045, context),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {});
                          },
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
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => MusicPlayer(
                                                    audioPlayer: audioPlayer,
                                                    songModel: items.data!,
                                                    index: index,
                                                    sliderVal: sliderValue,
                                                    fromFavScreen: false,
                                                  )))
                                          .then((value) {
                                        setState(() {});
                                      });
                                      
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
                                    title: myText(items.data![index].title,  mediaqueryWidth(0.049, context),
                                        Colors.white),
                                    trailing: PopupMenuButton<String>(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      color: Colors.grey,
                                      itemBuilder: (context) => [
                                        PopupMenuItem<String>(
                                          value: 'playlist',
                                          child: myText("Add to playlist",  mediaqueryWidth(0.046, context),
                                              Colors.black),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'favorites',
                                          child: myText("Add to favorites", mediaqueryWidth(0.046, context),
                                              Colors.black),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'share',
                                          child:
                                              myText("Share", mediaqueryWidth(0.046, context), Colors.black),
                                        ),
                                        PopupMenuItem(
                                          value: "details",
                                          child: myText(
                                              "Details", mediaqueryWidth(0.046, context), Colors.black),
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
                                                    items.data![index].songid,
                                                title:
                                                    items.data![index].title);

                                            addToFavoritesAlert(context);
                                            break;
                                          case 'share':
                                            await shareSong(items.data![index]);
                                            break;

                                          case 'details':
                                            detailsAlert(
                                                context: context,
                                                path: items.data![index].path,
                                                artist:
                                                    items.data![index].artist,
                                                title:
                                                    items.data![index].title);
                                            break;
                                         
                                        }
                                      },
                                      icon: FaIcon(FontAwesomeIcons.ellipsis,
                                          color: greyColor2),
                                    ),
                                    subtitle: myText(
                                        items.data![index].artist.toString(),
                                        mediaqueryWidth(0.039, context),
                                        const Color.fromARGB(
                                            255, 145, 145, 145)),
                                  ),
                                   Divider(
                                    indent:  mediaqueryHeight(0.0935, context),
                                    thickness: 1,
                                    color: const Color.fromARGB(255, 103, 103, 103),
                                  ),
                                ],
                              );
                            },
                            itemCount: items.data!.length,
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
    );
  }

  speedControl(BuildContext context, double initialSliderValue) {
    showDialog(
      context: context,
      builder: (ctx2) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: const Color.fromARGB(255, 0, 70, 84),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    myText(
                      "${(0.5 + initialSliderValue * 1.5).toStringAsFixed(1)}x",
                      mediaqueryHeight(0.025, context),
                      Colors.white,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16.0,
                          ),
                          trackShape: CustomTrackShape(),
                        ),
                        child: Slider(
                          value: initialSliderValue,
                          onChanged: (double value) {
                            setState(() {
                              initialSliderValue = value;
                              sliderValue = value;
                              double speed = 0.5 + value * 1.5;
                              audioPlayer.setSpeed(speed);
                            });
                          },
                          divisions: 14,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        myText("0.5x",  mediaqueryHeight(0.02, context), Colors.white),
                        myText("2.0x",   mediaqueryHeight(0.02, context), Colors.white)
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  bottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx2) {
          return Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF153B43), Colors.black])),
              height: mediaqueryHeight(0.5, context),
              child: Column(
                children: [
                   SizedBox(
                    height: mediaqueryHeight(0.023, context),
                  ),
                  GestureDetector(
                      onTap: () {
                        speedControl(context, sliderValue);
                      },
                      child: bottomSheetItems(Icons.speed, "Playback speed",context)),
                  divider(),
                  GestureDetector(
                      onTap: () {},
                      child: bottomSheetItems(Icons.share, "Share",context)),
                  divider(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PrivacyPolicy()));
                    },
                    child: bottomSheetItems(
                        Icons.privacy_tip_outlined, "Privacy policy",context),
                  ),
                  divider(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const TermsAndConditions()));
                    },
                    child: bottomSheetItems(
                        FontAwesomeIcons.clipboard, "Terms & Conditions",context),
                  ),
                  divider(),
                  bottomSheetItems(FontAwesomeIcons.star, "Rate us",context),
                   SizedBox(
                    height: mediaqueryHeight(0.03, context),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 18),
                    child: Text(
                      "Version 1.0.0",
                      style: TextStyle(
                          color: Colors.grey,
                          fontFamily: "FiraSans",
                          fontSize: 12),
                    ),
                  )
                ],
              ));
        });
  }
}

Widget bottomSheetItems(IconData icon, String text,context) {
  return Column(
    children: [
     SizedBox(
        height: mediaqueryHeight(0.01, context),
      ),
      Row(
        children: [
           Padding(padding: EdgeInsets.only(left: mediaqueryHeight(0.026, context))),
          Icon(
            icon,
            color: Colors.white,
            size: mediaqueryHeight(0.04, context),
          ),
          Expanded(
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "FiraSans",
                    fontSize: mediaqueryHeight(0.025, context)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
           SizedBox(
            width: mediaqueryHeight(0.04, context),
          )
        ],
      ),
       SizedBox(height: mediaqueryHeight(0.009, context)),
    ],
  );
}

divider() {
  return Column(
    children: [
      Divider(thickness: 2, color: const Color(0xFF555555).withOpacity(0.6)),
    ],
  );
}
