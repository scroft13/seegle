import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:seegle/services/auth_service.dart';

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
  bool _isLoading = true;
  bool _acceptsNotifications = false;
  bool _isAdmin = false;

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
          _acceptsNotifications =
              userDoc.data()?['acceptsNotifications'] ?? false;
          _isAdmin = userDoc.data()?['isAdmin'] ?? false;
          _usernameController.text = _username;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_currentUser != null) {
      setState(() {
        _acceptsNotifications = value;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({"acceptsNotifications": value});

      if (value) {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .update({"fcmToken": token});
        }
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .update({"fcmToken": FieldValue.delete()});
      }
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top section with email and gear icon inline
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Email: $_email",
                        style: const TextStyle(fontSize: 16),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.settings, size: 28),
                        onSelected: (value) {
                          if (value == 'delete') {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (context) => Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Are you sure you want to delete your account?',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (_currentUser != null) {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(_currentUser!.uid)
                                              .delete();
                                          await _currentUser!.delete();
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                            authService.signOut(context);
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text("Confirm Delete"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete Account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Username section and change username field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Username: $_username",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Change Username",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: _updateUsername,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SwitchListTile(
                        title: const Text("Enable Notifications"),
                        value: _acceptsNotifications,
                        onChanged: _toggleNotifications,
                      ),
                    ],
                  ),
                  // Admin-only section for requested flocks
                  if (_isAdmin)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Requested Flocks",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('requested_flocks')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }
                            final requests = snapshot.data!.docs;
                            if (requests.isEmpty) {
                              return const Text("No pending requests.");
                            }
                            return Column(
                              children: requests.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return Card(
                                  child: ListTile(
                                    title: Text(data['flockName']),
                                    subtitle: Text(data['description']),
                                    trailing: ElevatedButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('flocks')
                                            .doc(data['uniqueFlockName'])
                                            .set({
                                          ...data,
                                          "createdAt":
                                              FieldValue.serverTimestamp(),
                                          "createdBy": _currentUser!.uid,
                                        });
                                        await FirebaseFirestore.instance
                                            .collection('requested_flocks')
                                            .doc(doc.id)
                                            .delete();
                                      },
                                      child: const Text("Approve"),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  // Sign Out button at the bottom
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => authService.signOut(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Sign Out",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
