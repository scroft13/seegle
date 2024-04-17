import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:seegle/screens/home_wrapper.dart';
import 'package:seegle/screens/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/auth_wrapper.dart';

bool? seenOnboard;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  SharedPreferences pref = await SharedPreferences.getInstance();
  seenOnboard = pref.getBool('seenOnboard') ?? false;
  Firebase.initializeApp();
  runApp(
    const Seegle(),
  );
}

class Seegle extends StatelessWidget {
  final Color customYellow = const Color(0xFFFFCC02);
  final Color customGray = const Color(0xFF333333);
  // MaterialColor yellaMap = color2;

  const Seegle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild!.unfocus();
        }
      },
      child: GetMaterialApp(
        title: 'Seegle',
        theme: ThemeData(
          primaryColor: customGray,
          appBarTheme: const AppBarTheme(
              color: Color(0xFFFFFFFF),
              elevation: 0,
              foregroundColor: Color(0xFFFFCC00),
              iconTheme: IconThemeData(color: Color(0xFF333333))),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          sliderTheme: const SliderThemeData(
            activeTrackColor: Color(0xFFFFCC00),
            inactiveTrackColor: Color(0xFF333333),
            thumbColor: Color(0xFFFFCC00),
            trackHeight: 2,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFFCC00),
            foregroundColor: Color(0xFF333333),
            enableFeedback: true,
          ),
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                style: BorderStyle.solid,
                color: Color(0xFFFFCC00),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          buttonTheme: ButtonTheme.of(context).copyWith(
              buttonColor: const Color(0xFFFFCC00),
              height: 35,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontFamily: 'NexaLight', color: customGray),
          ),
        ),
        debugShowCheckedModeBanner: true,
        home: seenOnboard == true
            // ? HomeWrapper()
            ? AuthWrapper(
                // analytics: analytics,
                // observer: observer,
                )
            : const OnBoardingPage(),
      ),
    );
  }
}
