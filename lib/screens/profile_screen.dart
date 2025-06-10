import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:seegle/services/auth_service.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final AuthService authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  User? _currentUser;
  String _email = '';
  String _username = '';
  String? _profileImageUrl;
  bool _isLoading = true;
  bool _isAdmin = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _email = _currentUser!.email ?? 'No email available';
          _username = userDoc.data()?['username'] ?? 'No username set';
          _isAdmin = userDoc.data()?['isAdmin'] ?? false;
          _usernameController.text = _username;
          _profileImageUrl = userDoc.data()?['profileImageUrl'];
          _isLoading = false;
        });
      }

      final settingsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('notification_settings')
          .doc('profile')
          .get();

      if (settingsDoc.exists) {
        final settings = settingsDoc.data()!;
        _notificationsEnabled = settings['notificationsEnabled'] ?? true;
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null && _currentUser != null) {
        final file = File(pickedFile.path);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads')
            .child(_currentUser!.uid)
            .child('profile.jpg');
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .update({'profileImageUrl': downloadUrl});

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated!')),
          );
        }
      }
    }
  }

  Future<void> _updateNotificationsEnabled(bool value) async {
    setState(() => _notificationsEnabled = value);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('notification_settings')
        .doc('profile')
        .set({'notificationsEnabled': value}, SetOptions(merge: true));
  }

  Future<void> _updateUsername() async {
    if (_currentUser != null && _usernameController.text.isNotEmpty) {
      final newUsername = _usernameController.text.trim();
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);
      final usernamesRef = FirebaseFirestore.instance.collection('usernames');

      // Check if the username already exists
      DocumentSnapshot existingUsernameDoc =
          await usernamesRef.doc(newUsername).get();
      if (existingUsernameDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Username is already taken. Please choose another.')),
          );
        }
        return;
      }

      DocumentSnapshot userDoc = await userRef.get();
      String oldUsername = userDoc.exists
          ? (userDoc.data() as Map<String, dynamic>)['username'] ?? ''
          : '';

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Update user's username
        transaction.update(userRef, {'username': newUsername});

        // Remove old username from usernames collection
        if (oldUsername.isNotEmpty) {
          transaction.delete(usernamesRef.doc(oldUsername));
        }

        // Add new username to usernames collection
        transaction
            .set(usernamesRef.doc(newUsername), {'uid': _currentUser!.uid});
      });

      setState(() {
        _username = newUsername;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username updated successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Profile Card
                          Neumorphic(
                            style: NeumorphicStyle(
                              depth: 10,
                              intensity: 0.9,
                              surfaceIntensity: 0.1,
                              shape: NeumorphicShape.concave,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(20)),
                              color: const Color(0xFFFFFFFF),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 16),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundImage: _profileImageUrl !=
                                                null
                                            ? NetworkImage(_profileImageUrl!)
                                            : null,
                                        child: _profileImageUrl == null
                                            ? const Icon(
                                                CupertinoIcons.person_alt,
                                                size: 50,
                                                color:
                                                    CupertinoColors.systemGrey)
                                            : null,
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        minSize: 0,
                                        onPressed: _uploadProfileImage,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: CupertinoColors.systemGrey5,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          child: const Icon(
                                              CupertinoIcons.camera,
                                              size: 22),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _username.isNotEmpty
                                        ? _username
                                        : 'No username set',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _email,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: const Text('Delete Account',
                                        style: TextStyle(
                                            color: CupertinoColors.systemRed)),
                                    onPressed: () {
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (context) =>
                                            CupertinoActionSheet(
                                          title: const Text('Delete Account'),
                                          message: const Text(
                                              'Are you sure you want to delete your account?'),
                                          actions: [
                                            CupertinoActionSheetAction(
                                              isDestructiveAction: true,
                                              onPressed: () async {
                                                if (_currentUser != null) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(_currentUser!.uid)
                                                      .delete();
                                                  await _currentUser!.delete();
                                                  if (context.mounted) {
                                                    Navigator.of(context).pop();
                                                    authService
                                                        .signOut(context);
                                                  }
                                                }
                                              },
                                              child:
                                                  const Text('Confirm Delete'),
                                            ),
                                          ],
                                          cancelButton:
                                              CupertinoActionSheetAction(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Username change section
                          Neumorphic(
                            style: NeumorphicStyle(
                              depth: 10,
                              intensity: 0.9,
                              surfaceIntensity: 0.1,
                              shape: NeumorphicShape.concave,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(20)),
                              color: const Color(0xFFFFFFFF),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Change Username",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  CupertinoTextField(
                                    controller: _usernameController,
                                    placeholder: "Enter new username",
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    suffix: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      minSize: 0,
                                      onPressed: _updateUsername,
                                      child: const Icon(
                                          CupertinoIcons
                                              .check_mark_circled_solid,
                                          color: CupertinoColors.activeGreen),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Notifications section
                          Neumorphic(
                            style: NeumorphicStyle(
                              depth: 10,
                              intensity: 0.9,
                              surfaceIntensity: 0.1,
                              shape: NeumorphicShape.concave,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(20)),
                              color: const Color(0xFFFFFFFF),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Notifications",
                                      style: TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: Icon(
                                      _notificationsEnabled
                                          ? CupertinoIcons.bell_solid
                                          : CupertinoIcons.bell_slash,
                                      color: _notificationsEnabled
                                          ? const Color(0xFFFFCC00)
                                          : CupertinoColors.systemGrey,
                                    ),
                                    tooltip: _notificationsEnabled
                                        ? 'Disable Notifications'
                                        : 'Enable Notifications',
                                    onPressed: () async {
                                      final newValue = !_notificationsEnabled;
                                      setState(() =>
                                          _notificationsEnabled = newValue);
                                      await _updateNotificationsEnabled(
                                          newValue);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!_notificationsEnabled)
                            const Padding(
                              padding: EdgeInsets.only(top: 6.0),
                              child: Text(
                                'Notifications are disabled for all flocks.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey),
                                textAlign: TextAlign.right,
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(top: 6.0),
                              child: Text(
                                'This setting controls all flock notifications.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemGrey),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          const SizedBox(height: 24),
                          // Admin-only section for requested flocks
                          if (_isAdmin)
                            Container(
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Requested Flocks",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('requested_flocks')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CupertinoActivityIndicator();
                                      }
                                      final requests = snapshot.data!.docs;
                                      if (requests.isEmpty) {
                                        return const Text(
                                            "No pending requests.");
                                      }
                                      return Column(
                                        children: requests.map((doc) {
                                          final data = doc.data()
                                              as Map<String, dynamic>;
                                          return Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: ListTile(
                                              title: Text(data['flockName']),
                                              subtitle:
                                                  Text(data['description']),
                                              trailing: CupertinoButton.filled(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12),
                                                child: const Text("Approve"),
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('flocks')
                                                      .doc(data[
                                                          'uniqueFlockName'])
                                                      .set({
                                                    ...data,
                                                    "createdAt": FieldValue
                                                        .serverTimestamp(),
                                                    "createdBy":
                                                        _currentUser!.uid,
                                                  });
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'requested_flocks')
                                                      .doc(doc.id)
                                                      .delete();
                                                },
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 32),
                          // Sign Out button
                          CupertinoButton(
                            color: CupertinoColors.systemRed,
                            borderRadius: BorderRadius.circular(10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            child: const Text("Sign Out",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: CupertinoColors.white)),
                            onPressed: () => authService.signOut(context),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
