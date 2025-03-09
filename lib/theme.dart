// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Serif', // Adjust for an elegant font
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        shadowColor: Colors.black54,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 0),
        ),
        margin: const EdgeInsets.all(8),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: 'Serif',
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'Serif',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black, width: 2),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        hintStyle: const TextStyle(color: Colors.black54),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFFFCC00); // Color when the switch is ON
          }
          return Colors.grey; // Color when the switch is OFF
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.grey[300]!.withOpacity(0.4); // Active track color
          }
          return Colors.grey.withOpacity(0.4); // Inactive track color
        }),
        trackOutlineColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFFFCC00)
                .withOpacity(0.8); // Active track border color
          }
          return Colors.grey.withOpacity(0.8); // Inactive track border color
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white, // White background for contrast
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(
              color: Colors.black, width: 1), // Black border for separation
        ),
        elevation: 5, // Slight elevation for depth
        modalBackgroundColor: Colors.white, // For modal bottom sheets
        modalBarrierColor:
            Colors.black.withOpacity(0.3), // Subtle backdrop effect
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
            Color(0xFF0000FF),
          ),
          textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
            (states) {
              return TextStyle(
                fontSize: 18, // Set the desired text size
                fontWeight:
                    FontWeight.bold, // You can also add other properties
              );
            },
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white, // change the background color here
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // optional: rounded corners
        ),
      ),
    );
  }
}
