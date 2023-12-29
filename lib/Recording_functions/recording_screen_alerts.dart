import 'package:flutter/material.dart';

import 'package:lazits/Recording_functions/recording_screen_functions.dart';
import 'package:lazits/Reusable_widgets/app_theme.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:lazits/screens/recorder_screen.dart';

saveDialogue(BuildContext context, VoidCallback callback) {
  showDialog(
    context: context,
    builder: (ctx2) {
      return AlertDialog(
        backgroundColor: greyColor2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Center(
          child: myText("Save recording", 18, Colors.black),
        ),
        actions: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Color(0xFF153438)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: myText("Cancel", 16, Colors.white),
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll(Color(0xFF153438)),
                  ),
                  onPressed: () async {
                    await saveRecording(() {
                      callback();
                    }, context);
                  },
                  child: myText("Save", 16, Colors.white),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

void deleteAlert(
    BuildContext context, VoidCallback first, VoidCallback second) {
  showDialog(
      context: context,
      builder: (ctx2) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: greyColor2,
          title: const Center(
            child: Text(
              "Delete recording",
              style:  TextStyle(
                fontFamily: "FiraSans",
                color: Colors.black,
                fontSize: 20,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: myText("Cancel   ", 20, Colors.black)),
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.black,
                ),
                TextButton(
                    onPressed: () {
                      deleteRecording(filepath!, () {
                        first();
                      }, context);
                      second();
                    },
                    child: myText("   Delete", 20, Colors.red))
              ],
            )
          ],
          actionsPadding: const EdgeInsets.only(bottom: 10),
          titlePadding: const EdgeInsets.only(bottom: 10, top: 20),
        );
      });
}
