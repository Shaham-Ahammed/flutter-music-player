import 'package:flutter/material.dart';

PopupMenuButton<String?> menuButton(List<String> items) {
  return PopupMenuButton<String?>(
    itemBuilder: (context) => items.map((text) {
      return PopupMenuItem<String?>(
        value: text,
        child: Text(text),
      );
    }).toList(),
  );
}

