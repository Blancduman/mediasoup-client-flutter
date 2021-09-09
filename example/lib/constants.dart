import 'package:flutter/material.dart';

class Constants {
  static final theme = ThemeData(
    backgroundColor: Color(0xfffcfcff),
    primaryColor: Color(0xfffcfcff),
    accentColor: Colors.orange,
    scaffoldBackgroundColor: Color(0xfffcfcff),
    appBarTheme: AppBarTheme(
      elevation: 0,
      textTheme: TextTheme(
        headline6: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.orangeAccent,
    ),
  );
}
