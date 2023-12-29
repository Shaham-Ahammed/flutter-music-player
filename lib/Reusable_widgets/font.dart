import 'package:flutter/material.dart';


myText(String text, double size, Color color) {
  return Text(text,
  style: TextStyle(
    fontFamily: "FiraSans",
    color: color,
    fontSize: size,
     overflow: TextOverflow.ellipsis,
  ),
  );
}
