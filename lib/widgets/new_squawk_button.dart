import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seegle/store/store.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class NewSquawkButton extends StatefulWidget {
  const NewSquawkButton({super.key});

  @override
  NewSquawkButtonState createState() => NewSquawkButtonState();
}

class NewSquawkButtonState extends State<NewSquawkButton> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _squawkController = TextEditingController();
  TextEditingController _linkController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _mediaUrl;
  bool uploading = false;

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
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
              const Text(
                "New Squawk",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title (Required)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _squawkController,
                decoration: const InputDecoration(
                  labelText: "Message (Required)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: "Link (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: uploading ? null : _pickAndStoreMedia,
                icon: uploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : (_mediaUrl != null
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.camera_alt)),
                label: Text(uploading
                    ? "Uploading..."
                    : (_mediaUrl != null ? "Uploaded" : "Add Photo or Video")),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addSquawk,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text("Post Squawk"),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndStoreMedia() async {
    final User? user = _auth.currentUser;
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final String? choice = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Select Media Type"),
            content:
                const Text("Would you like to take a photo or record a video?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, "photo"),
                child: const Text("Take Photo"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, "video"),
                child: const Text("Record Video"),
              ),
            ],
          );
        },
      );

      if (choice == null) {
        debugPrint("User canceled media selection");
        return;
      }

      XFile? mediaFile;
      if (choice == "photo") {
        mediaFile = await picker.pickImage(source: ImageSource.camera);
      } else if (choice == "video") {
        mediaFile = await picker.pickVideo(source: ImageSource.camera);
      }

      if (mediaFile != null) {
        File file = File(mediaFile.path);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child("uploads/${user?.uid}/$fileName");

        try {
          setState(() {
            uploading = true;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
          UploadTask uploadTask = storageRef.putFile(file);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();

          setState(() {
            _mediaUrl = downloadUrl;
            uploading = false;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
          debugPrint("Media uploaded: $_mediaUrl");
        } catch (e) {
          debugPrint("Upload failed: $e");
          setState(() {
            uploading = false;
          });
        }
      } else {
        debugPrint("No media captured");
      }
    } else {
      debugPrint("Camera permission denied");
    }
  }

  Future<void> _addSquawk() async {
    final String title = _titleController.text.trim();
    final String squawkText = _squawkController.text.trim();
    final String link = _linkController.text.trim();
    final User? firebaseUser = _auth.currentUser;

    if (title.isEmpty) {
      debugPrint("Title is required");
      return;
    }

    if (squawkText.isEmpty) {
      debugPrint("Squawk message is required");
      return;
    }

    if (firebaseUser == null) {
      debugPrint("User is not authenticated");
      return;
    }

    final String flockId =
        Provider.of<AppStore>(context, listen: false).flockId;

    if (flockId.isEmpty) {
      debugPrint("Invalid flockId provided");
      return;
    }

    try {
      final userDoc =
          await _firestore.collection("users").doc(firebaseUser.uid).get();
      if (!userDoc.exists) {
        debugPrint("User document does not exist");
        return;
      }

      final String username = userDoc.data()?["username"] ?? "Unknown";
      final DateTime now = DateTime.now();

      final Map<String, dynamic> squawkData = {
        "title": title,
        "createdBy": firebaseUser.uid,
        "username": username,
        "createdAt": now,
        "message": squawkText,
        "comments": []
      };

      if (link.isNotEmpty) {
        squawkData["link"] = link;
      }

      if (_mediaUrl != null && _mediaUrl!.isNotEmpty) {
        squawkData["mediaUrl"] = _mediaUrl;
      }

      final flockDoc = await _firestore.collection("flocks").doc(flockId).get();
      if (!flockDoc.exists) {
        debugPrint("Flock document does not exist: $flockId");
        return;
      }

      await _firestore.collection("flocks").doc(flockId).update({
        "squawks": FieldValue.arrayUnion([squawkData]),
      });

      if (mounted) {
        Navigator.of(context).pop();
      }

      _titleController.clear();
      _squawkController.clear();
      _linkController.clear();
      _mediaUrl = null;
    } catch (e) {
      debugPrint("Firestore write error: $e");
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
