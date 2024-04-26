import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:simpleBTP/assets/colors.dart';

PreferredSizeWidget AppTopBar(title, Map<String, dynamic>? action) {
  Box box = Hive.box('settings');
  bool isDarkMode = box.get('darkMode', defaultValue: false);
  return AppBar(
    title: Text(title, style: const TextStyle(color: Colors.white)),
    iconTheme: const IconThemeData(color: Colors.white),
    actions: action != null
        ? [
            IconButton(
              icon: Icon(
                action['icon'],
                size: 30,
              ),
              onPressed: action['onPressed'],
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
