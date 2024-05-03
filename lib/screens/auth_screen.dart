import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:seegle/widgets/app_bar.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home Page',
        showExitButton: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SignInButton(
              Buttons.Google,
              onPressed: () async {
                await _authService.signInWithGoogle(context);
              },
              text: "Sign in with Google",
            ),
            SignInButton(
              Buttons.Apple,
              onPressed: () async {
                await _authService.signInWithApple(context);
              },
              text: "Sign in with Apple",
            ),
          ],
        ),
      ),
    );
  }
}
