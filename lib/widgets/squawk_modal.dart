import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/screens/video_player_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seegle/user_provider.dart';

class SquawkModal extends StatelessWidget {
  final Map<String, dynamic> squawk;

  const SquawkModal({super.key, required this.squawk});

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();

    void submitComment() async {
      final commentText = commentController.text.trim();
      if (commentText.isEmpty) return;

      final currentUser = FirebaseAuth.instance.currentUser;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String username = userProvider.user?.username ?? 'Unknown';
      final newComment = {
        'userId': currentUser?.uid ?? '',
        'username': username,
        'message': commentText,
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('squawks')
          .doc((squawk['docRef'] as DocumentReference).id)
          .collection('comments')
          .add(newComment);

      commentController.clear();
    }

    final pageController = PageController();
    final currentPageNotifier = ValueNotifier<int>(0);

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      squawk['title'] ?? 'Untitled Squawk',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("By ${squawk['username'] ?? 'Unknown User'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mediumGrey,
                      )),
                  Text(
                    squawk['createdAt'] != null
                        ? DateFormat('hh:mm MMM d, y')
                            .format((squawk['createdAt'] as Timestamp).toDate())
                        : "Unknown date",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (squawk['mediaUrls'] != null &&
                  squawk['mediaUrls'] is List &&
                  (squawk['mediaUrls'] as List).isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: (squawk['mediaUrls'] as List).length,
                        onPageChanged: (index) =>
                            currentPageNotifier.value = index,
                        itemBuilder: (context, index) {
                          final mediaUrl = squawk['mediaUrls'][index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: squawk['mediaType'] == 'video'
                                ? VideoPlayerScreen(videoUrl: mediaUrl)
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Scaffold(
                                            backgroundColor: Colors.black,
                                            appBar: AppBar(
                                              backgroundColor:
                                                  Colors.transparent,
                                            ),
                                            body: Center(
                                              child: InteractiveViewer(
                                                child: CachedNetworkImage(
                                                  imageUrl: mediaUrl,
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(
                                                          Icons.broken_image,
                                                          size: 100,
                                                          color: AppColors
                                                              .mediumGrey),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: mediaUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.broken_image,
                                              size: 100,
                                              color: AppColors.mediumGrey),
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: currentPageNotifier,
                      builder: (context, currentPage, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            (squawk['mediaUrls'] as List).length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: currentPage == index ? 10 : 8,
                              height: currentPage == index ? 10 : 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentPage == index
                                    ? AppColors.primaryColor
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Text(squawk['message'] ?? '',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              const Text("Comments",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return TextField(
                    controller: commentController,
                    minLines: 1,
                    maxLines: 6,
                    onSubmitted: (_) => submitComment(),
                    decoration: InputDecoration(
                      labelText: "Add a comment...",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: submitComment,
                      ),
                    ),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('squawks')
                    .doc((squawk['docRef'] as DocumentReference).id)
                    .collection('comments')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error loading comments: ${snapshot.error}");
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("No comments yet.");
                  }

                  final commentDocs = snapshot.data!.docs;

                  return Column(
                    children: commentDocs.map((doc) {
                      final comment = doc.data() as Map<String, dynamic>? ?? {};
                      final createdAt =
                          (comment['createdAt'] as Timestamp?)?.toDate();
                      final formattedDate = createdAt != null
                          ? DateFormat('hh:mm a, MMM d').format(createdAt)
                          : "Unknown time";

                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(comment['username'] ?? 'Unknown User',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  comment['edited'] == true
                                      ? '$formattedDate • edited'
                                      : formattedDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mediumGrey,
                                  ),
                                ),
                                if (comment['userId'] ==
                                    FirebaseAuth.instance.currentUser?.uid) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 16),
                                    onPressed: () {
                                      final controller = TextEditingController(
                                        text: comment['message'] ?? '',
                                      );
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Edit Comment'),
                                          content: TextField(
                                            controller: controller,
                                            maxLines: 3,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                final newMessage =
                                                    controller.text.trim();
                                                if (newMessage.isNotEmpty &&
                                                    newMessage !=
                                                        comment['message']) {
                                                  await doc.reference.update({
                                                    'message': newMessage,
                                                    'edited': true,
                                                  });
                                                  if (!context.mounted) return;
                                                }
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 16),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Comment'),
                                          content: const Text(
                                              'Are you sure you want to delete this comment?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                await doc.reference.delete();
                                                if (!context.mounted) return;
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(comment['message'] ?? ''),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
