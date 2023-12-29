// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazits/screens/all_songs_screen.dart';
import 'package:lazits/screens/recorder_screen.dart';

final file = Directory("storage/emulated/0/Download/lazit recordings");

String pathToRecordings = file.path;

startRecording(VoidCallback recording) async {
  audioPlayer.pause();
  await recorder.openRecorder();

  if ((await file.exists())) {
    print("exist");
  } else {
    print("not exist");
    file.create();
  }

  String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  String filePaths = '$pathToRecordings/Recording_$timestamp.aac';

  try {
    await recorder.startRecorder(
      toFile: filePaths,
    );
    recording();

    filepath = filePaths;
  } catch (e) {
    print("error starting recorder $e");
  }
}

saveRecording(VoidCallback stopped, context) async {
  await recorder.stopRecorder();
  debugPrint("stopped");
  stopped();

  Navigator.of(context).pop();
}

pauseRecording() async {
  await recorder.pauseRecorder();
}

resumeRecording() async {
  await recorder.resumeRecorder();
}

deleteRecording(String filepath, VoidCallback deleted, context) async {
  try {
    await recorder.stopRecorder(); 

    

    File file = File(filepath);

    if (await file.exists()) {
     
      await file.delete();
      print("Deleted: $filepath");
    } else {
      print("File does not exist: $filepath");
    }
    deleted();
    Navigator.pop(context);
  } catch (e) {
    print("Error deleting file: $e");

  }
}
