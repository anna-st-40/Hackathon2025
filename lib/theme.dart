import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 16.0),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.green,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
