import 'package:flutter/material.dart';
import 'package:seegle/size_configs.dart';

Color seegleYellow = const Color(0xffFFCC00);
Color seegleGray = const Color(0xff333333);
Color seegleLightGray = const Color(0xff999999);

abstract class Styles {
  static const TextStyle subTitle = TextStyle(
    color: Color(0xFF333333),
    fontSize: 19,
    fontFamily: 'NexaLight',
  );
  static const TextStyle categoryText = TextStyle(
    color: Color(0xFF333333),
    fontSize: 24,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.normal,
    fontFamily: 'Nexa',
  );
  static const TextStyle questionText = TextStyle(
    color: Color(0xFF333333),
    fontSize: 14,
    // fontStyle: FontStyle.italic,
  );
  static const TextStyle questionCategory = TextStyle(
    color: Color(0xFF333333),
    backgroundColor: Color(0xFFFFCC00),
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle buttonText = TextStyle(
    color: Color(0xFF333333),
    fontFamily: 'Nexa',
    fontSize: 18,
  );
  static const TextStyle bigMaizeText = TextStyle(
    color: Color(0xFFFFCC00),
    fontFamily: 'Nexa',
    fontSize: 24,
  );
  static TextStyle postCallBodyText = TextStyle(
    fontSize: 20,
    color: seegleGray,
    fontFamily: 'Nexa',
  );
  static TextStyle postCallBodyTextRed = const TextStyle(
    fontSize: 20,
    color: Color(0xffFF0000),
    fontFamily: 'Nexa',
  );
}

final kTitle = TextStyle(
    fontFamily: 'Nexa',
    fontSize: SizeConfig.blockSizeH! * 7,
    color: seegleGray);

final kBodyText1 = TextStyle(
  color: seegleGray,
  fontSize: SizeConfig.blockSizeH! * 4.5,
  fontWeight: FontWeight.bold,
);

class AppColors {
  static const Color primaryColor = Color(0xFFFFCC00);
  static const Color darkGrey = Color(0xFF333333);
  static const Color mediumGrey = Color(0xFFaaaaaa);
  static const Color lightGrey = Color(0xFFdddddd);
  static const Color accentColor = Color(0xFFFF0266);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF333333);
}
