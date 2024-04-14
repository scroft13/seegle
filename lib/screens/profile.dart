import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Function to handle user sign-out
  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context)
          .pushReplacementNamed('/'); // Navigate back to the welcome screen
    } catch (e) {
      // If sign out fails, display a Snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to sign out. Try again.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Name: ${user?.displayName ?? "Not Available"}'),
            Text('Email: ${user?.email ?? "Not Available"}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signOut(context),
              child: const Text("Sign Out"),
              // style: ElevatedButton.styleFrom(
              //   primary: Colors.red, // Button color
              //   onPrimary: Colors.white, // Text color
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
