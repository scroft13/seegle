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
  final List<String> _mediaUrls = []; // Stores multiple media URLs
  bool uploading = false;
  String? mediaType;

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
                      onPressed: uploading ? null : _captureAndStoreMedia,
                      icon: _mediaUrls.isNotEmpty
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.camera_alt),
                      label: Text(
                          _mediaUrls.isNotEmpty ? "Uploaded" : "Add Photo"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: uploading ? null : _captureVideoAndStore,
                      icon: const Icon(Icons.videocam),
                      label: const Text("Add Video"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: uploading ? null : _addSquawk,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: uploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text("Uploading...")
                        ],
                      )
                    : const Text("Post Squawk"),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureAndStoreMedia() async {
    final User? user = _auth.currentUser;
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      bool captureMore = true;

      setState(() {
        uploading = true;
      });

      while (captureMore) {
        XFile? mediaFile = await picker.pickImage(source: ImageSource.camera);

        // Pick video if image is not selected
        if (mediaFile == null) {
          mediaFile = await picker.pickVideo(source: ImageSource.camera);
          setState(() {
            mediaType = 'video';
          });
        } else {
          setState(() {
            mediaType = 'image';
          });
        }

        if (mediaFile == null) {
          debugPrint("User canceled media capture");
          break; // Stop loop when user cancels
        }

        File file = File(mediaFile.path);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child("uploads/${user?.uid}/$fileName");

        try {
          UploadTask uploadTask = storageRef.putFile(file);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          _mediaUrls.add(downloadUrl); // Store each uploaded URL

          // Ask user if they want to take another photo or video
          captureMore = await _askToCaptureMore();
        } catch (e) {
          debugPrint("Upload failed: $e");
          break;
        }
      }

      setState(() {
        uploading = false;
      });

      debugPrint("Media uploaded: $_mediaUrls");
    } else {
      debugPrint("Camera permission denied");
    }
  }

  Future<void> _captureVideoAndStore() async {
    final User? user = _auth.currentUser;
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();

      setState(() {
        uploading = true;
      });

      final XFile? videoFile =
          await picker.pickVideo(source: ImageSource.camera);
      if (videoFile == null) {
        debugPrint("User canceled video capture");
        setState(() {
          uploading = false;
        });
        return;
      }

      File file = File(videoFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("uploads/${user?.uid}/$fileName");

      try {
        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        _mediaUrls.add(downloadUrl);
        mediaType = 'video';
      } catch (e) {
        debugPrint("Video upload failed: $e");
      }

      setState(() {
        uploading = false;
      });
    } else {
      debugPrint("Camera permission denied");
    }
  }

  Future<bool> _askToCaptureMore() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Capture Another Photo?"),
              content: const Text("Would you like to take another photo?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _addSquawk() async {
    final String title = _titleController.text.trim();
    final String squawkText = _squawkController.text.trim();
    final String link = _linkController.text.trim();
    final User? firebaseUser = _auth.currentUser;

    if (title.isEmpty || firebaseUser == null) {
      debugPrint("Title and authentication are required");
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
        "mediaType": mediaType ?? "image", // Add video support
        "comments": [],
        "mediaUrls": _mediaUrls // Store media URLs (images or video)
      };

      if (link.isNotEmpty) {
        squawkData["link"] = link;
      }

      final squawkDoc = await _firestore.collection("squawks").add(squawkData);
      final String squawkId = squawkDoc.id;

      await _firestore.collection("flocks").doc(flockId).update({
        "squawks": FieldValue.arrayUnion([squawkId]),
      });

      if (mounted) {
        Navigator.of(context).pop();
      }

      _titleController.clear();
      _squawkController.clear();
      _linkController.clear();
      _mediaUrls.clear(); // Clear after posting
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
