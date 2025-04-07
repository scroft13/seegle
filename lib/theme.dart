// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:seegle/styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xff333333),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff333333),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Serif',
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
          color: Color(0xff333333),
          fontFamily: 'Serif',
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Color(0xff333333),
          fontFamily: 'Serif',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff333333),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Color(0xff333333),
          side: const BorderSide(color: Color(0xff333333), width: 2),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color(0xff333333),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xff333333),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xff333333), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        hintStyle: const TextStyle(color: Colors.black54),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFFFCC00);
          }
          return AppColors.mediumGrey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.grey[300]!.withOpacity(0.4);
          }
          return Colors.grey.withOpacity(0.4);
        }),
        trackOutlineColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Color(0xFFFFCC00).withOpacity(0.8);
          }
          return Colors.grey.withOpacity(0.8);
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: Color(0xff333333), width: 1),
        ),
        elevation: 5,
        modalBackgroundColor: Colors.white,
        modalBarrierColor: Color(0xff333333).withOpacity(0.3),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(
            Color(0xFF0000FF),
          ),
          textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
            (states) {
              return TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              );
            },
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
