import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:seegle/user_provider.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoRecorderWidget extends StatefulWidget {
  final String title;

  const VideoRecorderWidget({super.key, required this.title});
  @override
  State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  XFile? _videoFile;
  VideoPlayerController? _videoPlayerController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _requestPermissions();
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high);
      try {
        await _cameraController?.initialize();
        setState(() {});
      } catch (e) {
        print('Error initializing camera: $e');
      }
    }
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  Future<void> _startRecording() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String videoDir = '${appDirectory.path}/Videos';
      await Directory(videoDir).create(recursive: true);
      final String currentTime =
          DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '$videoDir/$currentTime.mp4';

      try {
        await _cameraController?.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      } catch (e) {
        print('Error starting video recording: $e');
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController != null &&
        _cameraController!.value.isRecordingVideo) {
      try {
        _videoFile = await _cameraController?.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });
        if (_videoFile != null) {
          _videoPlayerController =
              VideoPlayerController.file(File(_videoFile!.path))
                ..initialize().then((_) {
                  setState(() {});
                  _videoPlayerController!.play();
                });
        }
      } catch (e) {
        print('Error stopping video recording: $e');
      }
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final String userId = userProvider.user?.uid ?? '';
        final String fileName =
            'videos/$userId/${DateTime.now().millisecondsSinceEpoch}.mp4';
        final Reference storageRef =
            FirebaseStorage.instance.ref().child(fileName);
        final UploadTask uploadTask =
            storageRef.putFile(File(_videoFile!.path));

        final TaskSnapshot taskSnapshot = await uploadTask;
        final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        var username = userProvider.user?.username ?? "No username available";
        var photoUrl = userProvider.user?.photoUrl;

        await FirebaseFirestore.instance.collection('squawks').add({
          'videoUrl': downloadUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'title': widget.title,
          'username': username,
          'photoUrl': photoUrl, // Example content
        });

        setState(() {
          _isUploading = false;
          _videoFile = null;
          _videoPlayerController = null;
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully!')),
        );
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload video: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // double cWidth = MediaQuery.of(context).size.width;
    double cHeight = MediaQuery.of(context).size.height * .8;
    return SingleChildScrollView(
      child: Stack(
        children: [
          CameraPreview(_cameraController!),
          Column(
            children: [
              SizedBox(height: cHeight),

              // ),

              _isRecording
                  ? ElevatedButton(
                      onPressed: _stopRecording,
                      child: const Text('Stop Recording'),
                    )
                  : ElevatedButton(
                      onPressed: _startRecording,
                      child: const Text('Start Recording'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
