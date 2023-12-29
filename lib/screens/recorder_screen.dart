// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lazits/Recording_functions/recording_screen_alerts.dart';
import 'package:lazits/Recording_functions/recording_screen_functions.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';
import 'package:lazits/Reusable_widgets/screen_widgets.dart';

final FlutterSoundRecorder recorder = FlutterSoundRecorder();
String? filepath;

class Recorder extends StatefulWidget {
  const Recorder({Key? key}) : super(key: key);

  @override
  RecorderState createState() => RecorderState();
}

class RecorderState extends State<Recorder> {
  bool isRecording = false;
  bool showButtons = false;
  bool isSaved = false;
  late Timer timer;
  final FlutterSoundPlayer _player;
  int seconds = 0;
  bool playRecording = false;
  bool started = false;
  RecorderState() : _player = FlutterSoundPlayer();

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (isRecording) {
        setState(() {
          seconds++;
        });
      }
    });
    recorder.openRecorder();
    _player.openPlayer();
    super.initState();
  }

  @override
  void dispose() async {
    await _player.closePlayer();

    if (!playRecording) {
      await deleteRecording(filepath!, () {}, context);
    }
    timer.cancel();

    super.dispose();
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
          child: SingleChildScrollView(
            child: Padding(
              padding: screenPadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  myText("Voice recorder", mediaqueryHeight(0.030, context), greyColor),
                  SizedBox(
                    height: mediaqueryHeight(0.16, context),
                  ),
                  Center(
                    child: myText(formatTime(seconds), mediaqueryHeight(0.07, context), Colors.white),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.10,
                  ),
                  Center(
                      child: started == false
                          ? IconButton(
                              onPressed: () async {
                                setState(() {
                                  started = true;
                                  isRecording = true;
                                  showButtons = false;
                                  playRecording = false;
                                });

                                await startRecording(() {});
                              },
                              icon:  Icon(
                                Icons.radio_button_checked,
                                size: mediaqueryHeight(0.08, context),
                                color: Colors.white,
                              ))
                          : null),
                  if (isRecording && started)
                    Center(
                        child: IconButton(
                            onPressed: () async {
                              setState(() {
                                isRecording = false;
                                showButtons = true;
                              });
                              await pauseRecording();
                            },
                            icon:  Icon(
                              Icons.pause_circle_outline_rounded,
                              size: mediaqueryHeight(0.08, context),
                              color: Colors.white,
                            ))),
                  if (!isRecording && started)
                    Center(
                      child: IconButton(
                          onPressed: () async {
                            setState(() {
                              isRecording = true;
                              showButtons = false;
                            });
                            await resumeRecording();
                          },
                          icon:  Icon(
                            Icons.play_circle_outline_outlined,
                            color: Colors.white,
                            size: mediaqueryHeight(0.08, context),
                          )),
                    ),
                  if (showButtons)
                    Padding(
                      padding:
                          EdgeInsets.only(top: mediaqueryHeight(0.08, context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: const Color(0xFFB82020),
                              size: mediaqueryHeight(0.047, context),
                            ),
                            onPressed: () {
                              deleteAlert(context, () {
                                setState(() {
                                  seconds = 0;
                                  isRecording = false;
                                  showButtons = false;
                                  playRecording = false;
                                });
                              }, () {
                                setState(() {
                                  isSaved = false;
                                  started = false;
                                });
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.save,
                                color: Colors.white,
                                size: mediaqueryHeight(0.047, context)),
                            onPressed: () {
                              saveDialogue(context, () {
                                setState(() {
                                  playRecording = true;
                                  started = false;
                                  seconds = 0;
                                });
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  if (playRecording)
                    Padding(
                      padding:
                          EdgeInsets.only(top: mediaqueryHeight(0.08, context)),
                      child: Center(
                        child: TextButton(
                            style: ButtonStyle(
                                fixedSize: MaterialStatePropertyAll(Size(
                                    mediaqueryWidth(0.45, context),
                                    mediaqueryWidth(0.1, context))),
                                backgroundColor: const MaterialStatePropertyAll(
                                    Color.fromARGB(255, 8, 81, 110))),
                            onPressed: () async {
                              await _playRecording();
                            },
                            child: Center(
                                child: Row(
                              children: [
                                Icon(
                                  Icons.keyboard_voice_outlined,
                                  color: greyColor,
                                  size: mediaqueryHeight(0.025, context),
                                ),
                                 SizedBox(
                                  width: mediaqueryHeight(0.009, context),
                                ),
                                Text(
                                  "play recording",
                                  style: TextStyle(
                                    fontFamily:
                                       "FiraSans",
                                    color: greyColor,
                                    fontSize: mediaqueryHeight(0.02, context),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ))),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatTime(int seconds) {
    Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  _playRecording() async {
    try {
      await _player.closePlayer(); // Close the player if it's open

      await _player.openPlayer(); // Open the player
      await _player.startPlayer(fromURI: filepath);
    } catch (e) {
      print("Error playing recording: $e");
      // Handle the error as needed
    }
  }
}
