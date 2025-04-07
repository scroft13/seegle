import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/user_provider.dart';
import 'package:seegle/widgets/app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:seegle/widgets/squawk_modal.dart';

class FlockDetailsScreen extends StatefulWidget {
  final String flockId;

  const FlockDetailsScreen({super.key, required this.flockId});

  @override
  FlockDetailsScreenState createState() => FlockDetailsScreenState();
}

class FlockDetailsScreenState extends State<FlockDetailsScreen> {
  String flockName = '';
  String flockDescription = '';
  String? createdBy;
  DateTime? createdAt;
  User? _currentUser;
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> squawks = [];
  bool _isLoading = false;
  bool _isDescriptionExpanded = false;
  bool _isEditingDescription = false;
  bool _hasRequestedJoin = false;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchSquawks();
  }

  Future<void> _approveRequest(
      String userId, String username, Timestamp requestedAt) async {
    try {
      await FirebaseFirestore.instance
          .collection('flocks')
          .doc(widget.flockId)
          .update({
        "members.$userId": {
          "username": username,
          "requestedAt": requestedAt,
        },
        "askedToJoin.$userId": FieldValue.delete(),
        "memberIds": FieldValue.arrayUnion([userId])
      });

      setState(() {});
    } catch (e) {
      debugPrint("Error approving request: $e");
    }
  }

  Future<void> _denyRequest(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('flocks')
          .doc(widget.flockId)
          .update({
        "askedToJoin.$userId": FieldValue.delete(),
      });

      setState(() {});
    } catch (e) {
      debugPrint("Error denying request: $e");
    }
  }

  Future<void> _requestToJoin() async {
    if (_currentUser == null) return;

    final userId = _currentUser!.uid;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String username = userProvider.user?.username ?? 'Unknown';

    try {
      await FirebaseFirestore.instance
          .collection('flocks')
          .doc(widget.flockId)
          .update({
        "askedToJoin.$userId": {
          "username": username,
          "requestedAt": Timestamp.now(),
        }
      });

      setState(() {
        _hasRequestedJoin = true;
      });
    } catch (e) {
      debugPrint("Error requesting to join: $e");
    }
  }

  Future<void> _fetchSquawks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot flockDoc = await FirebaseFirestore.instance
          .collection('flocks')
          .doc(widget.flockId)
          .get();

      if (flockDoc.exists) {
        final data = flockDoc.data() as Map<String, dynamic>;
        setState(() {
          flockName = data['flockName'] ?? 'Unnamed Flock';
          flockDescription = data['description'] ?? 'No description available.';
          createdAt = data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null;
          createdBy = data['createdBy'];
          bool isPrivate = data['isPrivate'] ?? false;
          List<dynamic> members = data['memberIds'] ?? [];
          _hasAccess = !isPrivate ||
              (members.contains(_currentUser?.uid ?? '')) ||
              createdBy == _currentUser?.uid;
          Map<String, dynamic>? askedToJoin = data['askedToJoin'];
          if (askedToJoin != null &&
              askedToJoin.containsKey(_currentUser?.uid)) {
            _hasRequestedJoin = true;
          } else {
            _hasRequestedJoin = false;
          }
        });
        final List<dynamic>? squawkIds = data['squawks'];
        if (squawkIds != null && squawkIds.isNotEmpty) {
          final List<Map<String, dynamic>> fetchedSquawks = [];

          final List<String> validSquawkIds = [];

          for (final entry in squawkIds) {
            if (entry is! String) {
              // Remove legacy squawk entry from the array
              await FirebaseFirestore.instance
                  .collection('flocks')
                  .doc(widget.flockId)
                  .update({
                "squawks": FieldValue.arrayRemove([entry]),
              });
              continue;
            }

            final doc = await FirebaseFirestore.instance
                .collection('squawks')
                .doc(entry)
                .get();
            if (doc.exists) {
              final squawkData = doc.data()!;
              squawkData['docRef'] = doc.reference;
              fetchedSquawks.add(squawkData);
              validSquawkIds.add(entry);
            }
          }

          fetchedSquawks.sort((a, b) => (b['createdAt'] as Timestamp)
              .compareTo(a['createdAt'] as Timestamp)); // Newest first
          setState(() {
            squawks = fetchedSquawks;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching squawks: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildMediaPreview(List<String> mediaUrls, {String? mediaType}) {
    if (mediaUrls.isEmpty) return SizedBox.shrink();

    if (mediaType == 'video') {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black,
            ),
            child: Image.network(
              '${mediaUrls.first}?thumbnail=true',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.videocam,
                size: 100,
                color: AppColors.mediumGrey,
              ),
            ),
          ),
          const Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: mediaUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(
          Icons.broken_image,
          size: 100,
          color: AppColors.mediumGrey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(flockId: widget.flockId),
      body: RefreshIndicator(
        onRefresh: _fetchSquawks,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flockName,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _isEditingDescription
                                ? TextField(
                                    controller: _descriptionController,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      labelText: "Edit Description",
                                      border: OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.check),
                                        onPressed: () {},
                                      ),
                                    ),
                                  )
                                : Text(
                                    flockDescription,
                                    maxLines: _isDescriptionExpanded ? null : 2,
                                    overflow: _isDescriptionExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.mediumGrey),
                                  ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (createdBy == _currentUser?.uid)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditingDescription =
                                            !_isEditingDescription;
                                      });
                                    },
                                    child: Text(_isEditingDescription
                                        ? "Cancel"
                                        : "Edit"),
                                  ),
                                if (flockDescription.length > 100 &&
                                    !_isEditingDescription)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isDescriptionExpanded =
                                            !_isDescriptionExpanded;
                                      });
                                    },
                                    child: Text(_isDescriptionExpanded
                                        ? "Show Less"
                                        : "More"),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (createdAt != null)
                          Text(
                            "Created on ${DateFormat('MMMM d, y').format(createdAt!)}",
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.mediumGrey),
                          ),
                        if (createdBy == _currentUser?.uid && _hasAccess) ...[
                          const SizedBox(height: 12),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('flocks')
                                .doc(widget.flockId)
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                return const SizedBox.shrink();
                              }

                              final data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final Map<String, dynamic>? requestedUsers =
                                  data['askedToJoin'];

                              if (requestedUsers == null ||
                                  requestedUsers.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Pending Join Requests:",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  ...requestedUsers.entries.map((entry) {
                                    final userId = entry.key;
                                    final userInfo =
                                        entry.value as Map<String, dynamic>;
                                    final username =
                                        userInfo['username'] ?? 'Unknown User';

                                    return ListTile(
                                      title: Text(username),
                                      subtitle: Text(
                                        "Requested at ${DateFormat('MMMM d, y hh:mm a').format((userInfo['requestedAt'] as Timestamp).toDate())}",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.check,
                                                color: Colors.green),
                                            onPressed: () => _approveRequest(
                                                userId,
                                                username,
                                                userInfo['requestedAt']),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _denyRequest(userId),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: !_hasAccess
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "This is a private flock. Request to join to see squawks.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed:
                                    _hasRequestedJoin ? null : _requestToJoin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasRequestedJoin
                                      ? Colors.grey
                                      : AppColors.primaryColor,
                                ),
                                child: Text(_hasRequestedJoin
                                    ? "Waiting for approval"
                                    : "Join"),
                              ),
                            ],
                          )
                        : squawks.isEmpty
                            ? const Center(
                                child: Text(
                                  "No squawks yet. Be the first to post!",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: squawks.length,
                                itemBuilder: (context, index) {
                                  final squawk = squawks[index];
                                  final Timestamp? createdAtTimestamp =
                                      squawk['createdAt'] as Timestamp?;
                                  String createdAtFormatted =
                                      createdAtTimestamp != null
                                          ? DateFormat('hh:mm MMMM d, y')
                                              .format(
                                                  createdAtTimestamp.toDate())
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
                                        builder: (context) =>
                                            SquawkModal(squawk: squawk),
                                      );
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              squawk['title'] ??
                                                  'Untitled Squawk',
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
                                                  color: AppColors.mediumGrey),
                                            ),
                                            const SizedBox(height: 8),
                                            if (squawk['mediaUrls'] != null)
                                              _buildMediaPreview(
                                                List<String>.from(
                                                    squawk['mediaUrls'] ?? []),
                                                mediaType: squawk['mediaType'],
                                              ),
                                            const SizedBox(height: 8),
                                            Text(
                                              squawk['message'] ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 8),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                createdAtFormatted,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.mediumGrey),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
      ),
    );
  }
}
