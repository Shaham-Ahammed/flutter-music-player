// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lazits/Reusable_widgets/mediaquery.dart';

Future<String?> getLyrics(String titles, String artists) async {
  const apiKey = '354a4928b7d6a23c6cae0d9112996da5';

  if (artists == "<unknown>") {
    return "unknown artist";
  }
  try {
    final response = await http.get(
      Uri.parse(
          'https://api.musixmatch.com/ws/1.1/matcher.lyrics.get?q_track=$titles&q_artist=$artists&apikey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['message']['body']['lyrics'] != null) {
        String lyrics = data['message']['body']['lyrics']['lyrics_body'];
        lyrics = lyrics.replaceAll(
            "******* This Lyrics is NOT for Commercial use *******", "");
        final lastIndex = lyrics.lastIndexOf('\n');
        if (lastIndex != -1) {
          lyrics = lyrics.substring(0, lastIndex);
        }
        return lyrics;
      } else {
        return 'Lyrics not found for this track';
      }
    } else {
      return 'Failed to fetch lyrics.Check your network connection.';
    }
  } catch (e) {
    debugPrint('Exception in getLyrics: $e');
    return null;
  }
}

showLyricsSheet(
    {required BuildContext context,
    required String title,
    required String artist}) async {
  final lyrics = await getLyrics(title, artist);
  if (lyrics == "unknown artist") {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding:
            EdgeInsets.symmetric(vertical: mediaqueryHeight(0.013, context)),
        content: Center(
          child: Text(
            'unknown artist',
            style: TextStyle(
                fontFamily:"FiraSans",
                fontSize: mediaqueryHeight(0.02, context)),
          ),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        duration: const Duration(seconds: 1),
      ),
    );
  } else if (lyrics != null) {
    Navigator.of(context).pop();
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(mediaqueryHeight(0.018, context)),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 199, 199, 199),
                    Color.fromARGB(255, 159, 159, 159)
                  ])),
          height: MediaQuery.of(context).size.height * 0.47,
          child: SingleChildScrollView(
            child: Text(
              lyrics,
              style: TextStyle(
                fontSize: mediaqueryHeight(0.02, context),
                fontFamily:"FiraSans",
              ),
            ),
          ),
        );
      },
    );
  } else {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding:
            EdgeInsets.symmetric(vertical: mediaqueryHeight(0.013, context)),
        content: Center(
          child: Text(
            'Lyrics not available',
            style: TextStyle(
                fontFamily: "FiraSans",
                fontSize: mediaqueryHeight(0.02, context)),
          ),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30))),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
