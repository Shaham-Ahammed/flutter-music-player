

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lazits/Db_Model/db_model.dart';
import 'package:share/share.dart';

Future<void> shareSong(Song sn) async {
  final song =sn;

  if (song.path.isNotEmpty) {
    final file = File(song.path);

    if (await file.exists()) {
      await Share.shareFiles([song.path]
         );
    } else {
      debugPrint('File not found: ${song.uri}');
    }
  } else {
    debugPrint('File path is empty');
  }
}
