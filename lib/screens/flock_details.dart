import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seegle/widgets/app_bar.dart';

class FlockDetailsScreen extends StatefulWidget {
  final String flockId;

  const FlockDetailsScreen({super.key, required this.flockId});

  @override
  FlockDetailsScreenState createState() => FlockDetailsScreenState();
}

class FlockDetailsScreenState extends State<FlockDetailsScreen> {
  bool _isExpanded = false;
  String flockName = '';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('flocks')
            .doc(widget.flockId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Flock not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          String description =
              data['description'] ?? "No description available";
          bool isPrivate = data['isPrivate'] ?? false;
          List<dynamic> squawks = data['squawks'] ?? [];
          List<dynamic> users = data['users'] ?? [];
          bool isUserInFlock =
              users.any((user) => user['UID'] == _currentUser?.uid);

          if (flockName.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                flockName = data['flockName'] ?? "Unnamed Flock";
              });
            });
          }

          String descriptionToDisplay = description.length > 100
              ? _isExpanded
                  ? description
                  : "${description.substring(0, 100)}..."
              : description;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flockName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descriptionToDisplay,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (description.length > 100)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? "Show Less" : "Show More",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Privacy: ",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(isPrivate ? "Private" : "Public",
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Squawks Section
                  const Text("Squawks:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  if (isPrivate && !isUserInFlock)
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement join functionality
                        },
                        child: const Text("Join Flock"),
                      ),
                    )
                  else if (squawks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "No squawks yet. Be the first to squawk!",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: squawks.length,
                      itemBuilder: (context, index) {
                        final squawk = squawks[index] as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  squawk['username'] ?? 'Unknown User',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  squawk['message'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    squawk['timestamp'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
