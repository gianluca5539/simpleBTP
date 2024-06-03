import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';

PreferredSizeWidget appTopBar(title, actions) {
  Box box = Hive.box('settings');
  bool isDarkMode = box.get('darkMode', defaultValue: false);
  return AppBar(
    toolbarHeight: 50,
    centerTitle: true,
    title: Text(title, style: const TextStyle(color: Colors.white)),
    iconTheme: const IconThemeData(color: Colors.white),
    actions: actions != null
        ? [
            IconButton(
              icon: Icon(
                actions[0]['icon'],
                size: 30,
              ),
              onPressed: actions[0]['onPressed'],
            ),
            IconButton(
              icon: Icon(
                actions[1]['icon'],
                size: 30,
              ),
              onPressed: actions[1]['onPressed'],
            )
          ]
        : null,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            primaryColor,
            isDarkMode ? secondaryColorDark : secondaryColor,
          ],
        ),
      ),
    ),
  );
}
