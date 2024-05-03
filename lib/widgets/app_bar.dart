import 'package:flutter/material.dart';
import 'package:seegle/screens/auth_screen.dart';
import 'package:seegle/services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showExitButton; // Whether to show the exit button
  final AuthService _authService = AuthService();

  CustomAppBar({
    required this.title,
    this.showExitButton = false, // Default to not showing the exit button
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading:
          false, // Assume we manage the leading widget ourselves
      actions: <Widget>[
        if (showExitButton)
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Exit App'),
                  content: Text(
                      'Are you sure you want to exit? You will be signed out completely.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AuthScreen(),
                          ),
                        ); // Close the dialog
                        _authService.signOut();

                        // Attempt to pop the current screen or exit the app
                      },
                      child: Text('Yes'),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
