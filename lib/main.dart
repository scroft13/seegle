import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seegle/screens/main_layout.dart';
import 'screens/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seegle',
      home: const AuthenticationWrapper(),
      routes: {
        // Adjust this if your initial screen is different
        '/home': (context) =>
            const MainLayout(), // Ensure this matches the route being pushed
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return WelcomeScreen();
          }
          return const MainLayout(); // Home screen is only returned if a user is signed in
        }
        // Return a loading indicator while waiting for the auth state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
