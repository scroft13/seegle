import 'package:flutter/material.dart';
import '../services/authentication.dart';

class WelcomeScreen extends StatelessWidget {
  final AuthenticationService _authService = AuthenticationService();

  WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome to Seegle")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                try {
                  await _authService.signInWithGoogle();
                  Navigator.of(context).pushReplacementNamed('/home');
                } catch (e) {
                  print("Failed to sign in with Google: $e");
                }
              },
              child: Text("Sign in with Google"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _authService.signInWithApple();
                  Navigator.of(context).pushReplacementNamed('/home');
                } catch (e) {
                  print("Failed to sign in with Apple: $e");
                }
              },
              child: Text("Sign in with Apple"),
            ),
          ],
        ),
      ),
    );
  }
}
