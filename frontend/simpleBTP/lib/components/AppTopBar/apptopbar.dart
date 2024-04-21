import 'package:flutter/material.dart';

PreferredSizeWidget AppTopBar(title) {
  return AppBar(
    title: Text(title, style: const TextStyle(color: Colors.white)),
    iconTheme: const IconThemeData(color: Colors.white),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF4E6CDE),
            Color(0xFF64E9FF),
          ],
        ),
      ),
    ),
  );
}
