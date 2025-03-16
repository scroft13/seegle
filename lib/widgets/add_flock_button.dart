import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFlockButton extends StatefulWidget {
  const AddFlockButton({super.key});

  @override
  _AddFlockButtonState createState() => _AddFlockButtonState();
}

class _AddFlockButtonState extends State<AddFlockButton> {
  final TextEditingController _flockNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPrivate = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        bool isPrivate = _isPrivate;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Create a Flock",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _flockNameController,
                    decoration: InputDecoration(
                      labelText: "Flock Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Private", style: TextStyle(fontSize: 16)),
                      Switch(
                        value: isPrivate,
                        onChanged: (bool value) {
                          setModalState(() {
                            isPrivate = value;
                          });
                          setState(() {
                            _isPrivate = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addFlock,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 45),
                    ),
                    child: Text("Create Flock"),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addFlock() async {
    final String flockName = _flockNameController.text.trim();
    final String description = _descriptionController.text.trim();
    final User? user = _auth.currentUser;

    if (flockName.isEmpty || description.isEmpty || user == null) {
      return;
    }

    try {
      await _firestore.collection("flocks").add({
        "flockName": flockName,
        "description": description,
        "isPrivate": _isPrivate,
        "createdBy": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
        "squawks": [],
        "users": [
          {'UID': user.uid, 'username': user.displayName}
        ]
      });

      Navigator.of(context).pop();
      _flockNameController.clear();
      _descriptionController.clear();
      setState(() {
        _isPrivate = false;
      });
    } catch (e) {
      print("Error adding flock: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.black),
        onPressed: _openBottomSheet,
      ),
    );
  }
}
