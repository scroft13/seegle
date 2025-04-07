import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seegle/styles.dart';

import '../services/auth_service.dart';

class PrivateScreen extends StatelessWidget {
  final Function(String) onFlockTap;
  PrivateScreen({super.key, required this.onFlockTap});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    String? uid = _authService.currentUser?.uid;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('flocks')
            .where('memberIds', arrayContains: uid)
            .where('isPrivate', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading flocks"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No private flocks available"));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Private Flocks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification:
                        (OverscrollIndicatorNotification overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 10),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final flock = snapshot.data!.docs[index];
                        final data = flock.data() as Map<String, dynamic>;

                        String flockName = data['flockName'] ?? "Unnamed Flock";
                        String description =
                            data['description'] ?? "No description available";

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.mediumGrey),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            title: Text(
                              flockName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(color: AppColors.mediumGrey),
                            ),
                            onTap: () => onFlockTap(flock.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
