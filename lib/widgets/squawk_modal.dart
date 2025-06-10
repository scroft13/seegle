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
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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

  Future<VideoPlayerController> _createVideoController(String videoUrl) async {
    final videoPlayerController = VideoPlayerController.network(videoUrl);
    await videoPlayerController.initialize();
    return videoPlayerController;
  }

  Future<ChewieController> _createChewiePlayer(String videoUrl) async {
    final videoPlayerController = await _createVideoController(videoUrl);
    return ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: false,
      looping: false,
    );
  }

  Widget _buildMediaDisplay() {
    final mediaUrls = widget.squawk['mediaUrls'] as List;

    // Handle both old and new data structures
    List<String> mediaTypes = [];
    if (widget.squawk['mediaTypes'] != null &&
        widget.squawk['mediaTypes'] is List) {
      // New structure with mediaTypes array
      mediaTypes = (widget.squawk['mediaTypes'] as List).cast<String>();
    } else if (widget.squawk['mediaType'] != null) {
      // Old structure with single mediaType string
      mediaTypes = [widget.squawk['mediaType'] as String];
    } else {
      // Fallback - determine type from URL
      mediaTypes = mediaUrls
          .map((url) => (url.toString().contains('.mp4') ||
                  url.toString().contains('.mov'))
              ? 'video'
              : 'image')
          .toList();
    }

    if (mediaUrls.length == 1) {
      // Single media item
      return _buildSingleMedia(
          mediaUrls[0], mediaTypes.isNotEmpty ? mediaTypes[0] : 'unknown');
    } else {
      // Multiple media items - show as carousel
      return _buildMediaCarousel(mediaUrls, mediaTypes);
    }
  }

  Widget _buildSingleMedia(String mediaUrl, String mediaType) {
    if (mediaType == 'video' ||
        mediaUrl.contains('.mp4') ||
        mediaUrl.contains('.mov')) {
      return _buildVideoPlayer(mediaUrl);
    } else {
      return _buildImageDisplay(mediaUrl);
    }
  }

  Widget _buildVideoPlayer(String videoUrl) {
    return FutureBuilder<VideoPlayerController>(
      future: _createVideoController(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final controller = snapshot.data!;

          // Auto-play the video
          if (!controller.value.isPlaying) {
            controller.play();
          }

          return GestureDetector(
            onTap: () {
              // Toggle play/pause on tap
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            },
            child: Container(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(controller),
                    // Play/pause overlay
                    if (!controller.value.isPlaying)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.play_arrow,
                              color: Colors.white, size: 40),
                          onPressed: () => controller.play(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }
        return Container(
          height: 200,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildImageDisplay(String imageUrl) {
    return Container(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            child: const Center(child: Icon(Icons.error)),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaCarousel(List mediaUrls, List<String> mediaTypes) {
    // Calculate optimal height based on content types
    bool hasVideo = mediaTypes.any((type) =>
        type == 'video' ||
        mediaUrls.any((url) =>
            url.toString().contains('.mp4') ||
            url.toString().contains('.mov')));

    // Use larger height if videos are present
    double carouselHeight = hasVideo ? 500 : 350;

    return Column(
      children: [
        SizedBox(
          height: carouselHeight,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) => currentPageNotifier.value = index,
            itemCount: mediaUrls.length,
            itemBuilder: (context, index) {
              final mediaUrl = mediaUrls[index];
              final mediaType =
                  index < mediaTypes.length ? mediaTypes[index] : 'unknown';
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildSingleMediaForCarousel(mediaUrl, mediaType),
              );
            },
          ),
        ),
        // Page indicator
        if (mediaUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ValueListenableBuilder<int>(
              valueListenable: currentPageNotifier,
              builder: (context, currentPage, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    mediaUrls.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == index
                            ? Colors.blue
                            : AppColors.mediumGrey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSingleMediaForCarousel(String mediaUrl, String mediaType) {
    if (mediaType == 'video' ||
        mediaUrl.contains('.mp4') ||
        mediaUrl.contains('.mov')) {
      return _buildVideoPlayerForCarousel(mediaUrl);
    } else {
      return _buildImageDisplayForCarousel(mediaUrl);
    }
  }

  Widget _buildVideoPlayerForCarousel(String videoUrl) {
    return FutureBuilder<VideoPlayerController>(
      future: _createVideoController(videoUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final controller = snapshot.data!;

          // Auto-play the video
          if (!controller.value.isPlaying) {
            controller.play();
          }

          return GestureDetector(
            onTap: () {
              // Toggle play/pause on tap
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(controller),
                      // Play/pause overlay
                      if (!controller.value.isPlaying)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(Icons.play_arrow,
                                color: Colors.white, size: 40),
                            onPressed: () => controller.play(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Container(
          height: 200,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildImageDisplayForCarousel(String imageUrl) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit
              .contain, // Changed from cover to contain to prevent cropping
          placeholder: (context, url) => Container(
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            child: const Center(child: Icon(Icons.error)),
          ),
        ),
      ),
    );
  }

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
              Text(widget.squawk['message'] ?? '',
                  style: const TextStyle(fontSize: 16)),

              // Media display section
              if (widget.squawk['mediaUrls'] != null &&
                  widget.squawk['mediaUrls'] is List &&
                  (widget.squawk['mediaUrls'] as List).isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _buildMediaDisplay(),
                ),

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
