import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:seegle/user_provider.dart';
import 'package:seegle/widgets/neu_button.dart';

class CreateSquawkButton extends StatelessWidget {
  const CreateSquawkButton({super.key});

  // Function to add a new squawk to Firestore
  Future<void> _createNewSquawk(context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var username = userProvider.user?.username ?? "No username available";
    CollectionReference squawks =
        FirebaseFirestore.instance.collection('squawks');
    try {
      // Add a new document with a generated ID
      await squawks.add({
        'title': 'New Squawk',
        'username': username, // Example content
        'timestamp': FieldValue.serverTimestamp(), // Add server timestamp
      });
      print("Squawk added successfully!");
    } catch (e) {
      print("Error adding squawk: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: NeumorphicButton(
        onPressed: () => _createNewSquawk(context),
        buttonText: 'Create New Squawk',
      ),
    );
  }
}
