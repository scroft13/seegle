import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final Function(String) onFlockTap;
  HomeScreen({super.key, required this.onFlockTap});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    User? user = _authService.currentUser;
    print('UID' + user!.uid);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('flocks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading flocks"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No flocks available"));
          }

          final flocks = snapshot.data!.docs;

          return Column(
            children: [
              Text('Public Flocks'),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  itemCount: flocks.length,
                  itemBuilder: (context, index) {
                    final flock = flocks[index];
                    final data = flock.data() as Map<String, dynamic>;

                    String flockName = data['flockName'] ?? "Unnamed Flock";
                    String description =
                        data['description'] ?? "No description available";

                    return !data['isPrivate']
                        ? Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(flockName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => onFlockTap(flock.id),
                            ),
                          )
                        : null;
                  },
                ),
              ),
              Text('Private Flocks'),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  itemCount: flocks.length,
                  itemBuilder: (context, index) {
                    final flock = flocks[index];
                    final data = flock.data() as Map<String, dynamic>;
                    print(data);
                    String flockName = data['flockName'] ?? "Unnamed Flock";
                    String description =
                        data['description'] ?? "No description available";
                    print('crearted' + data['createdBy']);
                    if (data['isPrivate'] && data['createdBy'] == user!.uid) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          title: Text(flockName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => onFlockTap(flock.id),
                        ),
                      );
                    } else
                      return SizedBox();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
