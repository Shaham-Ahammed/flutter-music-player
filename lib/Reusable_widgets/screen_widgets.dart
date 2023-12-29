import 'package:flutter/material.dart';
import 'package:lazits/Reusable_widgets/font.dart';
import 'package:lazits/Reusable_widgets/mediaquery.dart';

screenPadding(context) {
  return EdgeInsets.only(
      bottom: mediaqueryHeight(0, context),
      left: mediaqueryWidth(0.05, context),
      right: mediaqueryWidth(0.05, context),
      top: mediaqueryWidth(0.05, context));
}

screenHeader(String heading, context,Color color) {
  return Row(
    children: [
      GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: color,
          size: mediaqueryHeight(0.028, context),
        ),
      ),
      SizedBox(
        width: mediaqueryHeight(0.012, context),
      ),
      myText(heading, mediaqueryHeight(0.030, context), color)
    ],
  );
}

screenDivider(context) {
  return Divider(
    indent: mediaqueryHeight(0.0935, context),
    thickness: 1,
    color: const Color.fromARGB(255, 103, 103, 103),
  );
}
