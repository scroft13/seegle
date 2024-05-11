import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String photoUrl;

  const ProfilePictureWidget({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.account_circle,
              size: 20.0); // Default icon if image fails to load
        },
      ),
    );
  }
}
