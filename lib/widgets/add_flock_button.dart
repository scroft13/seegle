import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegle/user_provider.dart';
import 'dart:developer' as developer; // Import logging framework
import 'dart:math'; // Import Random for unique ID generation

class AddFlockButton extends StatefulWidget {
  const AddFlockButton({super.key});

  @override
  AddFlockButtonState createState() => AddFlockButtonState();
}

class AddFlockButtonState extends State<AddFlockButton> {
  final TextEditingController _flockNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPrivate = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _generateUniqueId(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<String> _generateUniqueNormalizedName(String baseName) async {
    String uniqueId;
    String newNormalizedName;
    bool exists;

    do {
      uniqueId = _generateUniqueId(5);
      newNormalizedName = "${baseName}_$uniqueId";

      final QuerySnapshot existingFlocks = await _firestore
          .collection("flocks")
          .where("uniqueFlockName", isEqualTo: newNormalizedName)
          .where("isPrivate", isEqualTo: true)
          .get();

      exists = existingFlocks.docs.isNotEmpty;
    } while (exists);

    return newNormalizedName;
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
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
                        value: _isPrivate,
                        onChanged: (bool value) {
                          setModalState(() {
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
    final User? firebaseUser = _auth.currentUser;

    if (flockName.isEmpty || description.isEmpty || firebaseUser == null) {
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String username = userProvider.user?.username ?? 'Unknown';

    String uniqueFlockName =
        flockName.replaceAll(RegExp(r"\s+"), "").toLowerCase();
    if (!uniqueFlockName.startsWith("#")) {
      uniqueFlockName = "#$uniqueFlockName";
    }

    if (!mounted) {
      return;
    }
    final BuildContext localContext = context;

    try {
      if (!_isPrivate) {
        final QuerySnapshot existingPublicFlocks = await _firestore
            .collection("flocks")
            .where("uniqueFlockName", isEqualTo: uniqueFlockName)
            .where("isPrivate", isEqualTo: false)
            .get();

        if (existingPublicFlocks.docs.isNotEmpty) {
          if (!localContext.mounted) return;
          showDialog(
            context: localContext,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text("Flock Name Taken"),
                content: const Text(
                    "A public flock with this name already exists. Please choose a different name."),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (localContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
          return;
        }
      } else {
        final QuerySnapshot existingPrivateFlocks = await _firestore
            .collection("flocks")
            .where("uniqueFlockName", isEqualTo: uniqueFlockName)
            .where("isPrivate", isEqualTo: true)
            .get();

        if (existingPrivateFlocks.docs.isNotEmpty) {
          uniqueFlockName =
              await _generateUniqueNormalizedName(uniqueFlockName);
        }
      }

      String? uid = firebaseUser.uid;

      if (_isPrivate) {
        DocumentReference newFlockRef =
            await _firestore.collection("flocks").add({
          "flockName": flockName,
          "uniqueFlockName": uniqueFlockName,
          "description": description,
          "isPrivate": _isPrivate,
          "createdBy": firebaseUser.uid,
          "createdAt": FieldValue.serverTimestamp(),
          "squawks": [],
          "banned": [],
          "memberIds": [firebaseUser.uid]
        });

        await newFlockRef.update({
          "members": {
            uid: {
              "username": username,
              "joinedAt": FieldValue.serverTimestamp(),
            }
          }
        });
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        DocumentReference newPubFlock =
            await _firestore.collection("requested_flocks").add({
          "flockName": flockName,
          "uniqueFlockName": uniqueFlockName,
          "description": description,
          "isPrivate": _isPrivate,
          "createdBy": firebaseUser.uid,
          "createdAt": FieldValue.serverTimestamp(),
          "squawks": [],
          "banned": [],
          "memberIds": [firebaseUser.uid]
        });
        await newPubFlock.update({
          "members": {
            uid: {
              "username": username,
              "joinedAt": FieldValue.serverTimestamp(),
            }
          }
        });
        if (localContext.mounted) {
          showDialog(
            context: localContext,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text("Request Submitted"),
                content: const Text(
                    "Your request for a public flock has been sent for approval."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      }

      _flockNameController.clear();
      _descriptionController.clear();
      setState(() {
        _isPrivate = true;
      });
    } catch (e) {
      developer.log("Error adding flock: $e", error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.black),
        onPressed: _openBottomSheet,
      ),
    );
  }
}
