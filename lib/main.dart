import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:seegle/screens/profile_screen.dart';
import 'user_provider.dart';
import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final Color customYellow = const Color(0xFFFFCC02);
  final Color darkGray = const Color(0xFF333333);
  final Color lightGray = const Color(0xFF666666);
  final Color primaryColor = const Color(0xFFFFCC00); // Yellow
  final Color backgroundColor = const Color(0xFF333333); // Dark gray
  final Color darkFontColor = const Color(0xFFCCCCCC);
  final Color secondaryColor =
      const Color(0xFFFF9800); // Example secondary color
  final Color onSecondaryColor = const Color(
      0xFF000000); // Typically a color that is visible on the secondary color
  final Color errorColor =
      const Color(0xFFB00020); // Standard material design error color
  final Color onErrorColor = const Color(0xFFFFFFFF); // Light gray

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        )
      ],
      child: MaterialApp(
          title: 'Seegle',
          initialRoute: '/',
          theme: ThemeData(
            colorScheme: ColorScheme(
              brightness: Brightness.light,
              primary: primaryColor,
              onPrimary: Colors
                  .black, // Ensuring text/icons on primary color are visible
              secondary: secondaryColor,
              onSecondary: onSecondaryColor,
              error: errorColor,
              onError: onErrorColor,
              background: Colors.white,
              onBackground: darkFontColor, // Text color for background areas
              surface: darkFontColor,
              onSurface: darkFontColor, // Inp)
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme(
              brightness: Brightness.dark,
              primary: primaryColor,
              onPrimary: Colors
                  .black, // Ensuring text/icons on primary color are visible
              secondary: secondaryColor,
              onSecondary: onSecondaryColor,
              error: errorColor,
              onError: onErrorColor,
              background: backgroundColor,
              onBackground: darkFontColor, // Text color for background areas
              surface: darkFontColor,
              onSurface: darkFontColor, // Inp)
            ),
            switchTheme: SwitchThemeData(
              trackColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return MaterialStateColor.resolveWith((states) =>
                        customYellow); // Color when button is pressed
                  }
                  return MaterialStateColor.resolveWith(
                      (states) => darkGray); // Default color
                },
              ),
              // overlayColor:
              //     MaterialStateColor.resolveWith((states) => lightGray),
              thumbColor: MaterialStateColor.resolveWith((states) => lightGray),
              trackOutlineColor:
                  MaterialStateColor.resolveWith((states) => lightGray),
            ),
          ),
          debugShowCheckedModeBanner: false,
          routes: {
            '/': (context) => AuthScreen(
                  shouldShowScaffold: true,
                ),
            '/profile': (context) => const ProfilePage(),
          }),
    );
  }
}
