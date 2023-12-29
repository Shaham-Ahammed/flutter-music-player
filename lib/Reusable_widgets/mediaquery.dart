
  import 'package:flutter/material.dart';

mediaqueryHeight(double value,context) {
    return MediaQuery.of(context).size.height * value;
  }

  mediaqueryWidth(double value,context) {
    return MediaQuery.of(context).size.width * value;
  }