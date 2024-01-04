// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lazits/Db_Model/db_model.dart';
import 'package:lazits/Db_function/db_function.dart';
import 'package:lazits/Reusable_widgets/add_to_playlist_alert.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:lazits/Reusable_widgets/lyrics_sheet.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';
import 'package:lazits/Reusable_widgets/network_connection_status.dart';
import 'package:lazits/Reusable_widgets/screen_widgets.dart';
import 'package:lazits/Reusable_widgets/share_fucntion.dart';
import 'package:lazits/provider/song_modal_provider.dart';
import 'package:lazits/screens/add_to_playslist.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

class MusicPlayer extends StatefulWidget {
  List<Song>? songModel;
  final AudioPlayer audioPlayer;
  int index;
  final bool fromFavScreen;
  final double? sliderVal;
  bool fromRecords;

  MusicPlayer(
      {Key? key,
      required this.songModel,
      required this.index,
      required this.audioPlayer,
      this.sliderVal,
      required this.fromFavScreen,
      this.fromRecords = false})
      : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer>
    with SingleTickerProviderStateMixin {
  double sliderValue = 0.36;
  late AnimationController _controller;
  bool isFavorite = false;
  bool isShuffle = false;
  bool isLoop = false;
  bool isPlaying = true;
  bool showLyrics = false;
  Duration duration = const Duration();
  Duration position = const Duration();
  int durationMinutes = 0;
  int durationSeconds = 0;
  int positionMinutes = 0;
  int positionSeconds = 0;
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<Duration?> _positionSubscription;

  void playSong() async {
    addSongToRecentlyPlayed(widget.songModel![widget.index].songid);
    addSongToMostPlayed(widget.songModel![widget.index].songid);
    try {
      await widget.audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.songModel![widget.index].uri),
          tag: MediaItem(
            id: "${widget.songModel![widget.index].songid}",
            album: widget.songModel![widget.index].artist,
            title: widget.songModel![widget.index].title,
            artUri: Uri.parse('https://example.com/albumart.jpg'),
          ),
        ),
      );

      await widget.audioPlayer.seek(Duration.zero);

      widget.audioPlayer.play();

      _durationSubscription = widget.audioPlayer.durationStream.listen((d) {
        setState(() {
          duration = d!;
          durationMinutes = duration.inMinutes;
          durationSeconds = duration.inSeconds.remainder(60);
        });
      });

      _positionSubscription = widget.audioPlayer.positionStream.listen((d) {
        setState(() {
          position = d;
          positionMinutes = position.inMinutes;
          positionSeconds = position.inSeconds.remainder(60);
        });
      });
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  bool isFetchingLyrics = false;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    checkIsFav();

    playSong();

    if (widget.sliderVal != null) {
      sliderValue = widget.sliderVal!;
      widget.audioPlayer.setSpeed(0.5 + sliderValue * 1.5);
    }

    widget.audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (!isLoop) {
          playNextSong();
          context
              .read<SongModalProvider>()
              .setId(widget.songModel![widget.index].songid);
        } else {
          widget.audioPlayer.seek(Duration.zero);
        }
      }
    });
    super.initState();
  }

  void toggleFavorite() async {
    final song = widget.songModel![widget.index];
    await checkIsFav();
    if (favoriteSongIds.contains(song.songid)) {
      removeSongFromFav(songId: song.songid);
      deleteFromFavoriteAlert(context);
    } else {
      await addSongToFav(songId: song.songid);
      addToFavoritesAlert(context);
    }
    await checkIsFav();
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
            child: Column(
          children: [
            Stack(
              children: [
                const ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Color.fromRGBO(255, 255, 255, 0.2),
                    BlendMode.dstIn,
                  ),
                  child: ArtWork(),
                ),
                Padding(
                  padding: screenPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: mediaqueryHeight(0.025, context),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => speedControl(context, sliderValue),
                            child: Icon(
                              Icons.speed,
                              size: mediaqueryHeight(0.032, context),
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .03,
                      ),
                      Stack(
                        children: [
                          isPlaying
                              ? RotationTransition(
                                  turns: _controller,
                                  child: const Center(
                                    child: ClipOval(child: ArtWork2()),
                                  ),
                                )
                              : const Center(
                                  child: ClipOval(child: ArtWork3()),
                                ),
                          Positioned(
                              top: MediaQuery.of(context).size.width * 0.23,
                              left: MediaQuery.of(context).size.width * 0.36,
                              child: Center(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.18,
                                  width:
                                      MediaQuery.of(context).size.width * 0.18,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width:
                                            mediaqueryHeight(0.0057, context),
                                        color: const Color.fromARGB(
                                            255, 191, 191, 191)),
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF153A42),
                                  ),
                                ),
                              )),
                          Positioned(
                              top: MediaQuery.of(context).size.width * 0.28,
                              left: MediaQuery.of(context).size.width * 0.41,
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.width * 0.08,
                                width: MediaQuery.of(context).size.width * 0.08,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 170, 170, 170)),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * .05,
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: SizedBox(
                            height: mediaqueryHeight(0.04, context),
                            child: Marquee(
                              text: widget.songModel![widget.index].title,
                              style: TextStyle(
                                fontFamily: "FiraSans",
                                color: Colors.white,
                                fontSize: mediaqueryHeight(0.03, context),
                              ),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              blankSpace: 20,
                              velocity: 30.0,
                              startPadding: 10.0,
                              accelerationDuration:
                                  const Duration(milliseconds: 500),
                              accelerationCurve: Curves.linear,
                              decelerationDuration:
                                  const Duration(milliseconds: 500),
                              decelerationCurve: Curves.easeOut,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Center(
                            child: Text(
                              widget.fromRecords == false
                                  ? widget.songModel![widget.index].artist
                                      .toString()
                                  : "",
                              style: TextStyle(
                                fontFamily: "FiraSans",
                                color: greyColor,
                                fontSize: mediaqueryHeight(0.02, context),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                      Center(
                          child: CustomInkWell(
                        onTap: () async {
                          bool netAvailable = await checkConnection();
                          if (netAvailable) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            );

                            await showLyricsSheet(
                              context: context,
                              artist: widget.songModel![widget.index].artist,
                              title: widget.songModel![widget.index].title,
                            );
                          } else {
                            netWorkErrorSnackbar(context);
                          }
                        },
                        child: Ink(
                          padding: EdgeInsets.symmetric(
                              vertical: mediaqueryHeight(0.019, context),
                              horizontal: mediaqueryHeight(0.022, context)),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: myText("Get lyrics",
                              mediaqueryHeight(0.019, context), Colors.white),
                        ),
                      )),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: screenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          );
                          try {
                            await shareSong(widget.songModel![widget.index]);
                          } finally {
                            Navigator.of(context).pop();
                          }
                        },
                        child: FaIcon(
                          FontAwesomeIcons.share,
                          color: Colors.white,
                          size: mediaqueryHeight(0.03, context),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          toggleFavorite();
                          setState(() {});
                        },
                        child: favoriteSongIds.contains(
                                widget.songModel![widget.index].songid)
                            ? FaIcon(
                                FontAwesomeIcons.solidHeart,
                                color: Colors.red,
                                size: mediaqueryHeight(0.03, context),
                              )
                            : FaIcon(
                                FontAwesomeIcons.heart,
                                color: Colors.white,
                                size: mediaqueryHeight(0.03, context),
                              ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => AddToPlayslist(
                                    song: widget.songModel![widget.index],
                                    fromAllSongsScreen: !widget.fromFavScreen)))
                            .then((value) {
                          setState(() {});
                        }),
                        child: FaIcon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                          size: mediaqueryHeight(0.03, context),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mediaqueryHeight(0.043, context),
                  ),
                  SliderTheme(
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
                      value: position.inSeconds.toDouble(),
                      min: const Duration(microseconds: 0).inSeconds.toDouble(),
                      max: duration.inSeconds.toDouble(),
                      onChanged: (double value) {
                        setState(() {
                          value =
                              value.clamp(0.0, duration.inSeconds.toDouble());
                          changeToSeconds(value.toInt());
                        });
                      },
                      activeColor: Colors.white,
                      inactiveColor: greyColor3,
                      thumbColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      myText(
                          '$positionMinutes:${positionSeconds.toString().padLeft(2, '0')}',
                          mediaqueryHeight(0.021, context),
                          Colors.white),
                      myText(
                          '$durationMinutes:${durationSeconds.toString().padLeft(2, '0')}',
                          mediaqueryHeight(0.021, context),
                          Colors.white)
                    ],
                  ),
                  SizedBox(
                    height: mediaqueryHeight(0.020, context),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          isShuffle = !isShuffle;
                        }),
                        child: FaIcon(
                          FontAwesomeIcons.shuffle,
                          color: isShuffle
                              ? const Color.fromRGBO(49, 186, 178, 1)
                              : Colors.white,
                          size: mediaqueryHeight(0.028, context),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: playPreviousSong,
                            child: FaIcon(
                              FontAwesomeIcons.backward,
                              color: Colors.white,
                              size: mediaqueryHeight(0.033, context),
                            ),
                          ),
                          SizedBox(
                            width: mediaqueryHeight(0.035, context),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              if (isPlaying) {
                                widget.audioPlayer.pause();
                              } else {
                                widget.audioPlayer.play();
                              }
                              isPlaying = !isPlaying;
                            }),
                            child: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: mediaqueryHeight(0.08, context),
                            ),
                          ),
                          SizedBox(
                            width: mediaqueryHeight(0.035, context),
                          ),
                          GestureDetector(
                            onTap: () {
                              playNextSong();
                            },
                            child: FaIcon(
                              FontAwesomeIcons.forward,
                              color: Colors.white,
                              size: mediaqueryHeight(0.033, context),
                            ),
                          )
                        ],
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          isLoop = !isLoop;
                        }),
                        child: FaIcon(
                          FontAwesomeIcons.repeat,
                          color: isLoop
                              ? const Color.fromRGBO(49, 186, 178, 1)
                              : Colors.white,
                          size: mediaqueryHeight(0.028, context),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        )),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _durationSubscription.cancel();
    _positionSubscription.cancel();

    super.dispose();
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

                              widget.audioPlayer.setSpeed(speed);
                            });
                          },
                          divisions: 14,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        myText("0.5x", mediaqueryHeight(0.02, context),
                            Colors.white),
                        myText("2.0x", mediaqueryHeight(0.02, context),
                            Colors.white)
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

  void changeToSeconds(int seconds) {
    Duration duration = Duration(seconds: seconds);
    widget.audioPlayer.seek(duration);
  }

  void playNextSong() {
    if (isShuffle) {
      int randomIndex;
      do {
        randomIndex = Random().nextInt(widget.songModel!.length);
      } while (randomIndex == widget.index);

      setState(() {
        widget.index = randomIndex;
        isPlaying = true;
      });

      int id;

      id = widget.songModel![widget.index].songid;

      context.read<SongModalProvider>().setId(id);

      setState(() {});
      playSong();
    } else {
      if (widget.index < widget.songModel!.length - 1) {
        setState(() {
          widget.index++;
          isPlaying = true;
        });
        int id;

        id = widget.songModel![widget.index].songid;

        context.read<SongModalProvider>().setId(id);
      }

      setState(() {});
      playSong();
    }
  }

  void playPreviousSong() {
    if (widget.index > 0) {
      setState(() {
        widget.index--;
        isPlaying = true;
      });

      context
          .read<SongModalProvider>()
          .setId(widget.songModel![widget.index].songid);

      setState(() {});
      playSong();
    }
  }
}

class ArtWork3 extends StatelessWidget {
  const ArtWork3({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongModalProvider>().id,
      type: ArtworkType.AUDIO,
      artworkFit: BoxFit.cover,
      artworkWidth: MediaQuery.of(context).size.width * 0.65,
      artworkHeight: MediaQuery.of(context).size.width * 0.65,
      artworkQuality: FilterQuality.high,
      artworkBorder: BorderRadius.circular(0),
      nullArtworkWidget: Image.asset(
        "assets/images/splash_logo.jpg",
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width * 0.65,
        height: MediaQuery.of(context).size.width * 0.65,
      ),
    );
  }
}

class ArtWork2 extends StatelessWidget {
  const ArtWork2({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongModalProvider>().id,
      type: ArtworkType.AUDIO,
      artworkFit: BoxFit.cover,
      artworkWidth: MediaQuery.of(context).size.width * 0.65,
      artworkHeight: MediaQuery.of(context).size.width * 0.65,
      artworkQuality: FilterQuality.high,
      artworkBorder: BorderRadius.circular(0),
      nullArtworkWidget: Image.asset(
        "assets/images/splash_logo.jpg",
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width * 0.65,
        height: MediaQuery.of(context).size.width * 0.65,
      ),
    );
  }
}

class ArtWork extends StatelessWidget {
  const ArtWork({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return QueryArtworkWidget(
      id: context.watch<SongModalProvider>().id,
      type: ArtworkType.AUDIO,
      artworkHeight: MediaQuery.of(context).size.height * 0.65,
      artworkWidth: double.infinity,
      artworkFit: BoxFit.cover,
      artworkQuality: FilterQuality.high,
      artworkBorder: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40)),
      nullArtworkWidget: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40)),
        child: Image.asset(
          "assets/images/splash_logo.jpg",
          height: MediaQuery.of(context).size.height * 0.65,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class CustomInkWell extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const CustomInkWell({Key? key, this.onTap, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        splashColor: const Color(0xFF153C44),
        child: ClipPath(
          clipper: MyClipper(),
          child: child,
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
        const Radius.circular(30)));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
