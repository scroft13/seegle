import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegle/user_provider.dart';
import 'package:seegle/widgets/profile_pic.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfileButton; // Whether to show the exit button

  const CustomAppBar({
    super.key,
    required this.title,
    this.showProfileButton = false, // Default to not showing the exit button
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return AppBar(
      title: Text(title),
      leading: Container(),
      automaticallyImplyLeading:
          false, // Assume we manage the leading widget ourselves
      actions: <Widget>[
        if (showProfileButton)
          ProfilePictureWidget(
            photoUrl: userProvider.user?.photoUrl ??
                '', // Replace with your actual URL
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
