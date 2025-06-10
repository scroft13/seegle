import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/screens/video_player_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seegle/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SquawkModal extends StatefulWidget {
  final Map<String, dynamic> squawk;
  const SquawkModal({super.key, required this.squawk});

  @override
  State<SquawkModal> createState() => _SquawkModalState();
}

class _SquawkModalState extends State<SquawkModal> {
  final TextEditingController commentController = TextEditingController();
  String? selectedGifUrl;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void submitComment() async {
    final commentText = commentController.text.trim();
    if (commentText.isEmpty && selectedGifUrl == null) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String username = userProvider.user?.username ?? 'Unknown';
    final newComment = {
      'userId': currentUser?.uid ?? '',
      'username': username,
      'message': commentText,
      'gifUrl': selectedGifUrl,
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('squawks')
        .doc((widget.squawk['docRef'] as DocumentReference).id)
        .collection('comments')
        .add(newComment);

    commentController.clear();
    setState(() {
      selectedGifUrl = null;
    });
    if (mounted) FocusScope.of(context).unfocus();
  }

  final pageController = PageController();
  final currentPageNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, sheetScrollController) {
        return SingleChildScrollView(
          controller: sheetScrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.squawk['title'] ?? 'Untitled Squawk',
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
                  Text("By ${widget.squawk['username'] ?? 'Unknown User'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mediumGrey,
                      )),
                  Text(
                    widget.squawk['createdAt'] != null
                        ? DateFormat('hh:mm MMM d, y').format(
                            (widget.squawk['createdAt'] as Timestamp).toDate())
                        : "Unknown date",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (widget.squawk['mediaUrls'] != null &&
                  widget.squawk['mediaUrls'] is List &&
                  (widget.squawk['mediaUrls'] as List).isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: (widget.squawk['mediaUrls'] as List).length,
                        onPageChanged: (index) =>
                            currentPageNotifier.value = index,
                        itemBuilder: (context, index) {
                          final mediaUrl = widget.squawk['mediaUrls'][index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: widget.squawk['mediaType'] == 'video'
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
                            (widget.squawk['mediaUrls'] as List).length,
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
              Text(widget.squawk['message'] ?? '',
                  style: const TextStyle(fontSize: 16)),
              if (widget.squawk['link'] != null &&
                  widget.squawk['link'].toString().isNotEmpty)
                FutureBuilder<Metadata?>(
                  future: MetadataFetch.extract(widget.squawk['link']),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return InkWell(
                        onTap: () async {
                          final url = Uri.parse(widget.squawk['link']);
                          try {
                            if (!await launchUrl(url,
                                mode: LaunchMode.externalApplication)) {
                              debugPrint(
                                  "Failed to launch $url. Try opening manually.");
                            }
                          } catch (e) {
                            debugPrint("Exception trying to launch $url: $e");
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 12.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.mediumGrey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.link, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.squawk['link'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final metadata = snapshot.data!;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final url = Uri.parse(widget.squawk['link']);
                          try {
                            final launched = await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                            if (!launched) {
                              debugPrint(
                                  "Failed to launch $url: no handler found.");
                            }
                          } catch (e) {
                            debugPrint("Exception trying to launch $url: $e");
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 12.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.mediumGrey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (metadata.image != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(metadata.image!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover),
                                ),
                              const SizedBox(height: 8),
                              if (metadata.title != null)
                                Text(metadata.title!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              if (metadata.description != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(metadata.description!),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  widget.squawk['link'],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 12),
              const Text("Comments",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.mediumGrey, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (selectedGifUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(selectedGifUrl!),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: IconButton(
                                    icon: const Icon(Icons.close),
                                    color: Colors.black54,
                                    onPressed: () =>
                                        setState(() => selectedGifUrl = null),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: selectedGifUrl != null ? 8.0 : 0.0,
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: TextField(
                            controller: commentController,
                            minLines: 1,
                            maxLines: 6,
                            onSubmitted: (_) => submitComment(),
                            decoration: InputDecoration(
                              labelText: "Add a comment...",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.gif_box),
                                    onPressed: () async {
                                      final gif = await GiphyGet.getGif(
                                        context: context,
                                        apiKey:
                                            dotenv.env['GIPHY_API_KEY'] ?? '',
                                        lang: GiphyLanguage.english,
                                      );
                                      if (gif != null) {
                                        final url = gif.images?.original?.url ??
                                            gif.images?.fixedHeight?.url ??
                                            gif.images?.downsized?.url;
                                        setState(() {
                                          selectedGifUrl = url;
                                        });
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: submitComment,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('squawks')
                    .doc((widget.squawk['docRef'] as DocumentReference).id)
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((comment['message'] ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(comment['message']),
                              ),
                            if (comment['gifUrl'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    comment['gifUrl'],
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                          ],
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
