import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegle/screens/auth_screen.dart';
import 'package:seegle/services/auth_service.dart';
import 'package:seegle/user_provider.dart';
import 'package:seegle/widgets/app_bar.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final username = userProvider.user?.username ?? "No username available";

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Home Page',
        showExitButton: true,
      ),
      body: Center(
        child: Text('Welcome ${username}!'),
      ),
    );
  }
}
