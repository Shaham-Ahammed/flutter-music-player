import 'package:flutter/material.dart';

import 'package:lazits/Reusable_widgets/mediaquery.dart';

detailsAlert(
    {required BuildContext context,
    required String title,
    required String path,
    required String artist}) {
  showDialog(
      context: context,
      builder: (ctx2) {
        return AlertDialog(
          elevation: 10,
          backgroundColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(0),
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey,
            ),
           
            padding:  EdgeInsets.all(mediaqueryHeight(0.023, context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Center(
                  child: Text(
                    "Song name",
                    style:  TextStyle(
                      fontFamily: "FiraSans",
                      color: Colors.black,
                      fontSize: mediaqueryHeight(0.025, context),
                    ),
                  ),
                ),
                sizedbox(mediaqueryHeight(0.01, context)),
                Text(
                  title,
                  style: TextStyle(
                      fontFamily: "FiraSans",
                    color: Colors.black,
                    fontSize:  mediaqueryHeight(0.02, context),
                  ),
                ),
                sizedbox(mediaqueryHeight(0.005,context)),
                divider(),
                Center(
                  child: Text(
                    "Artist",
                    style: TextStyle(
                      fontFamily: "FiraSans",
                      color: Colors.black,
                      fontSize: mediaqueryHeight(0.025, context),
                    ),
                  ),
                ),
                sizedbox(mediaqueryHeight(0.01, context)),
                Text(
                  artist,
                  style: TextStyle(
                    fontFamily: "FiraSans",
                    color: Colors.black,
                    fontSize:  mediaqueryHeight(0.02, context),
                  ),
                ),
                 sizedbox(mediaqueryHeight(0.005,context)),
                divider(),
                Center(
                  child: Text(
                    "Path",
                    style: TextStyle(
                       fontFamily: "FiraSans",
                      color: Colors.black,
                      fontSize: mediaqueryHeight(0.025, context),
                    ),
                  ),
                ),
                 sizedbox(mediaqueryHeight(0.01, context)),
                Text(
                  path,
                  style: TextStyle(
                    fontFamily: "FiraSans",
                    color: Colors.black,
                    fontSize:  mediaqueryHeight(0.02, context),
                  ),
                )
              ],
            ),
          ),
        );
      });
}

divider() {
  return const Divider(
    thickness: 1.5,
    color: Colors.black26,
  );
}

sizedbox(double size) {
  return SizedBox(
    height: size,
  );
}
