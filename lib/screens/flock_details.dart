import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(flockId: widget.flockId),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('flocks')
            .doc(widget.flockId)
            .snapshots(),
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

          List<dynamic> squawks = [];
          if (data['squawks'] is List<dynamic>) {
            squawks = data['squawks'];
          } else {
            debugPrint("Unexpected data type for squawks: ${data['squawks']}");
          }

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
                  const SizedBox(height: 16),
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
                        final Timestamp? createdAtTimestamp =
                            squawk['createdAt'] as Timestamp?;
                        String createdAtFormatted = createdAtTimestamp != null
                            ? DateFormat('hh:mm MMMM d, y')
                                .format(createdAtTimestamp.toDate())
                            : "Unknown date";

                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        squawk['title'] ?? 'Untitled Squawk',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "By ${squawk['username'] ?? 'Unknown User'}",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey),
                                      ),
                                      const SizedBox(height: 12),
                                      if (squawk['mediaUrl'] != null)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            squawk['mediaUrl'],
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 100,
                                                    color: Colors.grey),
                                          ),
                                        ),
                                      const SizedBox(height: 12),
                                      Text(
                                        squawk['message'] ?? '',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Comments",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('squawks')
                                            .doc(squawk['id'])
                                            .collection('comments')
                                            .orderBy('createdAt',
                                                descending: true)
                                            .snapshots(),
                                        builder: (context, commentSnapshot) {
                                          if (commentSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          if (!commentSnapshot.hasData ||
                                              commentSnapshot
                                                  .data!.docs.isEmpty) {
                                            return const Center(
                                                child:
                                                    Text("No comments yet."));
                                          }

                                          final comments =
                                              commentSnapshot.data!.docs;

                                          return SizedBox(
                                            height:
                                                200, // Fixed height for scrollable comments
                                            child: ListView.builder(
                                              itemCount: comments.length,
                                              itemBuilder: (context, index) {
                                                final comment =
                                                    comments[index].data()
                                                        as Map<String, dynamic>;
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  child: ListTile(
                                                    title: Text(
                                                      comment['username'] ??
                                                          'Unknown User',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    subtitle: Text(
                                                        comment['text'] ?? ''),
                                                    trailing: Text(
                                                      DateFormat(
                                                              'MMM d, y hh:mm a')
                                                          .format((comment[
                                                                      'createdAt']
                                                                  as Timestamp)
                                                              .toDate()),
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _commentController,
                                        decoration: InputDecoration(
                                          labelText: "Add a comment...",
                                          suffixIcon: IconButton(
                                            icon: const Icon(Icons.send),
                                            onPressed: () async {
                                              if (_commentController
                                                  .text.isNotEmpty) {
                                                await FirebaseFirestore.instance
                                                    .collection('squawks')
                                                    .doc(squawk['id'])
                                                    .collection('comments')
                                                    .add({
                                                  'text':
                                                      _commentController.text,
                                                  'username': _currentUser
                                                          ?.displayName ??
                                                      'Anonymous',
                                                  'createdAt': Timestamp.now(),
                                                });

                                                _commentController.clear();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    squawk['title'] ?? 'Untitled Squawk',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "By ${squawk['username'] ?? 'Unknown User'}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  if (squawk['mediaUrl'] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        squawk['mediaUrl'],
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 100,
                                                    color: Colors.grey),
                                      ),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    squawk['message'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      createdAtFormatted,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
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
