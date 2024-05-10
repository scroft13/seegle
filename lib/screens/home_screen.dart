import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegle/user_provider.dart';
import 'package:seegle/widgets/squawk_listener.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    var username = userProvider.user?.username ?? "No username available";

    return Scaffold(
      body: Center(
        // heightFactor: 20,
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text('Welcome $username!'),

                  const Expanded(
                      child: SizedBox(height: 500, child: SquawkListWidget())),
                  // Use the custom button widget
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
