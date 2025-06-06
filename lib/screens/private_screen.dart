import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../services/auth_service.dart';

class PrivateScreen extends StatelessWidget {
  final Function(String) onFlockTap;
  PrivateScreen({super.key, required this.onFlockTap});
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    String? uid = _authService.currentUser?.uid;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('flocks')
              .where('memberIds', arrayContains: uid)
              .where('isPrivate', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading flocks"));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No private flocks available"));
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                    child: Text(
                      'Private Flocks',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final flock = snapshot.data!.docs[index];
                      final data = flock.data() as Map<String, dynamic>;
                      String flockName = data['flockName'] ?? 'Unnamed Flock';
                      String description =
                          data['description'] ?? 'No description available';
                      return Neumorphic(
                        style: NeumorphicStyle(
                          depth: 10,
                          intensity: 0.9,
                          surfaceIntensity: 0.1,
                          shape: NeumorphicShape.concave,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(20)),
                          color: const Color(0xFFFFFFFF),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
                          child: CupertinoListTile(
                            title: Text(
                              flockName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            onTap: () => onFlockTap(flock.id),
                          ),
                        ),
                      );
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    );
  }
}
