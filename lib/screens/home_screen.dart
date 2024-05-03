import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegle/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    var username = userProvider.user?.username ?? "No username available";

    return Scaffold(
      body: Center(
        child: Text('Welcome $username!'),
      ),
    );
  }
}
