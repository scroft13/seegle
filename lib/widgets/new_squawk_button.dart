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
  final TextEditingController _linkController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _mediaUrls = [];
  String? _mediaType;
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
                  labelText: "Message (Optional)",
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: uploading
                          ? null
                          : () => _pickAndStoreMedia(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: uploading
                          ? null
                          : () => _pickAndStoreMedia(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Gallery"),
                    ),
                  ),
                ],
              ),
              if (_mediaUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "${_mediaUrls.length} file(s) uploaded",
                    style: const TextStyle(color: Colors.green),
                  ),
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

  Future<void> _pickAndStoreMedia(ImageSource source) async {
    final User? user = _auth.currentUser;

    // Request permission
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      // For gallery access, try photos permission first, fallback to storage for older Android
      status = await Permission.photos.request();
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final String? choice = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Select Media Type"),
            content: const Text("Would you like to select a photo or video?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, "photo"),
                child: const Text("Photo"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, "video"),
                child: const Text("Video"),
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
        mediaFile = await picker.pickImage(source: source);
        _mediaType = 'image';
      } else if (choice == "video") {
        mediaFile = await picker.pickVideo(source: source);
        _mediaType = 'video';
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

          UploadTask uploadTask = storageRef.putFile(file);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();

          setState(() {
            _mediaUrls.add(downloadUrl);
            uploading = false;
          });

          debugPrint("Media uploaded: $downloadUrl");
        } catch (e) {
          debugPrint("Upload failed: $e");
          setState(() {
            uploading = false;
          });
        }
      } else {
        debugPrint("No media selected");
      }
    } else {
      debugPrint("Permission denied");
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

    // Message is now optional - can post with just title and/or media

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
        "userId": firebaseUser.uid,
        "username": username,
        "createdAt": Timestamp.fromDate(now),
        "flockId": flockId,
      };

      // Only add message if it's not empty
      if (squawkText.isNotEmpty) {
        squawkData["message"] = squawkText;
      }

      if (link.isNotEmpty) {
        squawkData["link"] = link;
      }

      if (_mediaUrls.isNotEmpty) {
        squawkData["mediaUrls"] = _mediaUrls;
        squawkData["mediaType"] = _mediaType;
      }

      // Create the squawk as an individual document in the squawks collection
      await _firestore.collection("squawks").add(squawkData);

      if (mounted) {
        Navigator.of(context).pop();
      }

      _titleController.clear();
      _squawkController.clear();
      _linkController.clear();
      _mediaUrls.clear();
      _mediaType = null;
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
