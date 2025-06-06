import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class PublicScreen extends StatelessWidget {
  final Function(String) onFlockTap;
  const PublicScreen({super.key, required this.onFlockTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('flocks')
              .orderBy('squawks', descending: true)
              .orderBy('createdAt', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading flocks"));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No flocks available"));
            }

            final flocks = snapshot.data!.docs;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text(
                      'Public Flocks',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final flock = flocks[index];
                      final data = flock.data() as Map<String, dynamic>;
                      String flockName = data['flockName'] ?? "Unnamed Flock";
                      String description =
                          data['description'] ?? "No description available";
                      return !data['isPrivate']
                          ? Neumorphic(
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
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 6.0),
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
                            )
                          : const SizedBox();
                    },
                    childCount: flocks.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}
