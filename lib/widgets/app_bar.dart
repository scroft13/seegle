import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:seegle/widgets/add_flock_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 44,
      leading: Row(
        children: [
          const SizedBox(width: 16),
          const Text(
            'Seegle',
            style: TextStyle(
              fontSize: 26,
              color: Colors.black,
              fontFamily: 'NexaLight',
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            height: 32,
            child: Image.asset('assets/icon/icon.png', height: 32),
          ),
        ],
      ),
      leadingWidth: 160, // Adjust width based on your title & icon spacing
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0, right: 12),
          child: AddFlockButton(),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_sharp),
            color: Colors.black,
            iconSize: 28,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
