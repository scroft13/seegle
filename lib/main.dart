import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:seegle/screens/profile_screen.dart';
import 'package:seegle/store/store.dart';
import 'package:seegle/theme.dart';
import 'user_provider.dart';
import 'screens/auth_screen.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _setupFirebaseMessaging();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const Seegle());
}

Future<void> _setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permissions
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("Received a foreground message: ${message.notification?.title}");
  });

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint("User granted permission: ${settings.authorizationStatus}");
  } else {
    debugPrint("User declined notifications");
  }
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
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => AppStore()),
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
