import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:seegle/screens/profile_screen.dart';
import 'package:seegle/theme.dart';
import 'user_provider.dart';
import 'screens/auth_screen.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Seegle());
}

class Seegle extends StatelessWidget {
  const Seegle({super.key});
  final Color customYellow = const Color(0xFFFFCC02);
  final Color darkGray = const Color(0xFF999999);
  final Color lightGray = const Color(0xFFdddddd);
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
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        title: 'Seegle',
        initialRoute: '/',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => AuthScreen(
                shouldShowScaffold: true,
              ),
          '/profile': (context) => const ProfilePage(),
        },
      ),
    );
  }
}
