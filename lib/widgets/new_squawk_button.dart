import 'dart:io';
import 'dart:async';

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
  List<String> _mediaTypes = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  UploadTask? _currentUploadTask;
  StreamSubscription<TaskSnapshot>? _uploadSubscription;
  List<File> _selectedFiles = [];
  StateSetter? _progressDialogSetter;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _squawkController.dispose();
    _linkController.dispose();
    _uploadSubscription?.cancel();
    _currentUploadTask?.cancel();
    super.dispose();
  }

  void _resetState() {
    _titleController.clear();
    _squawkController.clear();
    _linkController.clear();
    _mediaUrls.clear();
    _mediaTypes.clear();
    _selectedFiles.clear();
    _isUploading = false;
    _uploadProgress = 0.0;
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return WillPopScope(
              onWillPop: () async {
                if (_isUploading) {
                  final shouldPop = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Upload in Progress'),
                      content: const Text(
                          'Are you sure you want to cancel the upload and close?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                  if (shouldPop == true) {
                    _currentUploadTask?.cancel();
                    _uploadSubscription?.cancel();
                  }
                  return shouldPop ?? false;
                }
                _resetState();
                return true;
              },
              child: Padding(
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      onChanged: (_) => setModalState(() {}),
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
                    if (_selectedFiles.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedFiles.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _mediaTypes[index] == 'image'
                                          ? Image.file(
                                              _selectedFiles[index],
                                              height: 80,
                                              width: 80,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              height: 80,
                                              width: 80,
                                              color: Colors.grey[300],
                                              child: const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.videocam,
                                                    size: 25,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    'Video',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          shape: BoxShape.circle,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            setModalState(() {
                                              _selectedFiles.removeAt(index);
                                              _mediaTypes.removeAt(index);
                                            });
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploading
                                ? null
                                : () => _pickAndStoreMedia(ImageSource.camera, setModalState),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Camera"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploading
                                ? null
                                : () => _pickAndStoreMedia(ImageSource.gallery, setModalState),
                            icon: const Icon(Icons.photo_library),
                            label: const Text("Gallery"),
                          ),
                        ),
                      ],
                    ),
                    if (_isUploading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            LinearProgressIndicator(value: _uploadProgress),
                            const SizedBox(height: 5),
                            Text(
                              'Posting... ${(_uploadProgress * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    if (_selectedFiles.isNotEmpty && !_isUploading)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedFiles.length == 1 && _mediaTypes.first == 'image' 
                                  ? Icons.photo 
                                  : _selectedFiles.length == 1 && _mediaTypes.first == 'video'
                                      ? Icons.videocam
                                      : Icons.collections,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${_selectedFiles.length} file${_selectedFiles.length > 1 ? 's' : ''} ready to post",
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: (!_isUploading &&
                              _titleController.text.trim().isNotEmpty)
                          ? _addSquawk
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: Text(_isUploading ? "Posting..." : "Post Squawk"),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => _resetState());
  }

  Future<void> _pickAndStoreMedia(ImageSource source, StateSetter setModalState) async {
    // Check if we already have 10 files
    if (_selectedFiles.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 files allowed'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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
      } else if (choice == "video") {
        mediaFile = await picker.pickVideo(
          source: source,
          maxDuration: const Duration(seconds: 30),
        );
      }

      if (mediaFile != null) {
        File file = File(mediaFile.path);
        setModalState(() {
          _selectedFiles.add(file);
          _mediaTypes.add(choice == "photo" ? 'image' : 'video');
        });
        debugPrint("Media selected locally: ${file.path}");
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

    // Close the current modal immediately
    Navigator.of(context).pop();
    
    // Show progress modal
    _showPostingProgress();

    // Reset state for the closed modal
    final List<File> filesToUpload = List.from(_selectedFiles);
    final List<String> mediaTypesToUpload = List.from(_mediaTypes);
    _resetState();

    try {
      final userDoc =
          await _firestore.collection("users").doc(firebaseUser.uid).get();
      if (!userDoc.exists) {
        debugPrint("User document does not exist");
        _showPostingError("User not found");
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

      if (squawkText.isNotEmpty) {
        squawkData["message"] = squawkText;
      }

      if (link.isNotEmpty) {
        squawkData["link"] = link;
      }

      // Upload media if we have any
      if (filesToUpload.isNotEmpty) {
        try {
          List<String> downloadUrls = [];
          
          for (int i = 0; i < filesToUpload.length; i++) {
            String fileName = "${DateTime.now().millisecondsSinceEpoch}_$i";
            Reference storageRef = FirebaseStorage.instance
                .ref()
                .child("uploads/${firebaseUser.uid}/$fileName");

            _currentUploadTask = storageRef.putFile(filesToUpload[i]);

            // Listen to upload progress
            _uploadSubscription = _currentUploadTask!.snapshotEvents.listen(
              (TaskSnapshot snapshot) {
                if (mounted) {
                  double progress = (i + (snapshot.bytesTransferred / snapshot.totalBytes)) / filesToUpload.length;
                  _updatePostingProgress(progress);
                }
              },
              onError: (error) {
                debugPrint("Upload progress error: $error");
                _showPostingError("Upload failed");
              },
            );

            TaskSnapshot snapshot = await _currentUploadTask!;

            // Check if the upload was cancelled
            if (snapshot.state == TaskState.canceled) {
              debugPrint("Upload was cancelled");
              _showPostingError("Upload cancelled");
              return;
            }

            String downloadUrl = await snapshot.ref.getDownloadURL();
            downloadUrls.add(downloadUrl);
            debugPrint("Media uploaded: $downloadUrl");
          }
          
          squawkData["mediaUrls"] = downloadUrls;
          squawkData["mediaTypes"] = mediaTypesToUpload;
        } catch (e) {
          debugPrint("Upload failed: $e");
          _showPostingError("Upload failed");
          return;
        }
      }

      // Create the squawk
      await _firestore.collection("squawks").add(squawkData);
      
      // Show success animation
      _showPostingSuccess();
      
    } catch (e) {
      debugPrint("Firestore write error: $e");
      _showPostingError("Failed to post squawk");
    }
  }

  void _showPostingProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setProgressState) {
            // Store the setState function for later use
            _progressDialogSetter = setProgressState;
            
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _uploadProgress,
                        strokeWidth: 6,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Posting...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _updatePostingProgress(double progress) {
    _uploadProgress = progress;
    // Update the dialog using its stored setState function
    _progressDialogSetter?.call(() {});
  }

  void _showPostingSuccess() {
    // Close progress dialog and clean up reference
    _progressDialogSetter = null;
    Navigator.of(context).pop();
    
    // Show success animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Post Successful!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    // Auto close after 1.5 seconds
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showPostingError(String message) {
    // Close progress dialog and clean up reference
    _progressDialogSetter = null;
    Navigator.of(context).pop();
    
    // Show error
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
