import 'package:flutter/material.dart';
import 'package:seegle/services/auth_service.dart';
import 'package:seegle/widgets/neu_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      body: Column(
        children: [
          const Center(
            child: Text("Settings content goes here"),
          ),
          NeumorphicButton(
            onPressed: () {
              authService.signOut(context);
            },
            buttonText: 'Sign Out',
          )
        ],
      ),
    );
  }
}
