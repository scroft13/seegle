import 'package:flutter/material.dart';
import 'package:seegle/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      body: Column(
        children: [
          const Center(child: Text("Settings content goes here")),
          TextButton(
              onPressed: () {
                authService.signOut(context);
                Navigator.of(context).popAndPushNamed('/');
              },
              child: const Text('Sign Out'))
        ],
      ),
    );
  }
}
