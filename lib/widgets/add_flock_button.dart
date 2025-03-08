import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFlockButton extends StatefulWidget {
  const AddFlockButton({Key? key}) : super(key: key);

  @override
  State<AddFlockButton> createState() => _AddFlockButtonState();
}

class _AddFlockButtonState extends State<AddFlockButton> {
  final _formKey = GlobalKey<FormState>();
  final _flockNameController = TextEditingController();
  bool _isPrivate = false;

  Future<void> _addFlock() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance.collection('flocks').add({
            'flockName': _flockNameController.text,
            'isPrivate': _isPrivate,
            'userId': user.uid,
          });
          // Clear the form and close the dialog.
          _flockNameController.clear();
          _isPrivate = false;
          Navigator.of(context).pop();
          // Optionally show a success message to the user.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Flock added successfully!')),
          );
        } catch (e) {
          // Handle errors appropriately, perhaps showing an error message.
          print("Error adding flock: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error adding flock.')),
          );
        }
      } else {
        // Handle the case where the user is not logged in.
        print("User not logged in.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add a flock.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add New Flock'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _flockNameController,
                      decoration:
                          const InputDecoration(labelText: 'Flock Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a flock name';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: <Widget>[
                        const Text('Private:'),
                        Switch(
                          value: _isPrivate,
                          onChanged: (value) {
                            setState(() {
                              _isPrivate = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _addFlock,
                  child: const Text('Add Flock'),
                ),
              ],
            );
          },
        );
      },
      child: const Text('Add Flock'),
    );
  }

  @override
  void dispose() {
    _flockNameController.dispose();
    super.dispose();
  }
}
