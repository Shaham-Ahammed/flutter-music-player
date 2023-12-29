import 'package:flutter/material.dart';
import 'package:lazits/Reusable_widgets/font.dart';

addToPlaylistAlert(
    {required BuildContext context, required String playlistName}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 5, left: 20, right: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: const Color.fromARGB(255, 8, 81, 110),
      duration: const Duration(seconds: 1),
      content: Center(
          child:
              myText("Song added to $playlistName playlist", 15, Colors.white)),
    ),
  );
}

addToFavoritesAlert(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 5, left: 20, right: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: const Color.fromARGB(255, 8, 81, 110),
      duration: const Duration(seconds: 1),
      content:
          Center(child: myText("Song Added to favorites", 15, Colors.white)),
    ),
  );
}

void deleteFromFavoriteAlert(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 5, left: 20, right: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 1),
      content: Center(
          child: myText("Song removed from favorites", 15, Colors.white)),
    ),
  );
}
