import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicScreen extends StatelessWidget {
  final Function(String) onFlockTap;
  const PublicScreen({super.key, required this.onFlockTap});

  @override
  Widget build(BuildContext context) {
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Public Flocks',
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
                      overscroll.disallowIndicator(); // Prevent glow effect
                      return true;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 10),
                      itemCount: flocks.length,
                      itemBuilder: (context, index) {
                        final flock = flocks[index];
                        final data = flock.data() as Map<String, dynamic>;

                        String flockName = data['flockName'] ?? "Unnamed Flock";
                        String description =
                            data['description'] ?? "No description available";
                        return !data['isPrivate']
                            ? Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          Colors.grey.shade300), // ✅ Add border
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
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  onTap: () => onFlockTap(flock.id),
                                ),
                              )
                            : const SizedBox();
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
