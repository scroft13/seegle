import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/user_provider.dart';
import 'package:seegle/widgets/app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:seegle/widgets/squawk_modal.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

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
  bool _flockNotificationsEnabled = true;
  bool _hasLoadedNotificationSettings = false;
  bool _globalNotificationsEnabled = true;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastSquawkDoc;
  static const int _batchSize = 10;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchFlockNotificationSetting();
    _fetchInitialSquawks();
    _scrollController.addListener(_onScroll);
    migrateSquawks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> migrateSquawks() async {
    final firestore = FirebaseFirestore.instance;
    final flocks = await firestore.collection('flocks').get();

    for (final flock in flocks.docs) {
      final flockId = flock.id;
      final squawkIds = (flock.data()['squawks'] as List?) ?? [];
      for (final squawkId in squawkIds) {
        final squawkRef = firestore.collection('squawks').doc(squawkId);
        await squawkRef.set({'flockId': flockId}, SetOptions(merge: true));
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore &&
        !_isLoading) {
      _fetchMoreSquawks();
    }
  }

  Future<void> _fetchInitialSquawks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final flockDoc = await FirebaseFirestore.instance
          .collection('flocks')
          .doc(widget.flockId)
          .get();
      if (flockDoc.exists) {
        final data = flockDoc.data() as Map<String, dynamic>;
        flockName = data['flockName'] ?? 'Unnamed Flock';
        flockDescription = data['description'] ?? 'No description available.';
        createdAt = data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : null;
        createdBy = data['createdBy'];
        bool isPrivate = data['isPrivate'] ?? false;
        final List<dynamic> members = data['memberIds'] ?? [];
        _hasAccess = !isPrivate ||
            (members.contains(_currentUser?.uid ?? '')) ||
            createdBy == _currentUser?.uid;
        Map<String, dynamic>? askedToJoin = data['askedToJoin'];
        if (askedToJoin != null && askedToJoin.containsKey(_currentUser?.uid)) {
          _hasRequestedJoin = true;
        } else {
          _hasRequestedJoin = false;
        }
        final query = await FirebaseFirestore.instance
            .collection('squawks')
            .where('flockId', isEqualTo: widget.flockId)
            .orderBy('createdAt', descending: true)
            .limit(_batchSize)
            .get();
        squawks = query.docs.map((doc) {
          final data = doc.data();
          data['docRef'] = doc.reference;
          return data;
        }).toList();
        if (query.docs.isNotEmpty) {
          _lastSquawkDoc = query.docs.last;
        }
        _hasMore = query.docs.length == _batchSize;
      }
    } catch (e) {
      debugPrint("Error fetching squawks: $e");
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchMoreSquawks() async {
    if (!_hasMore || _isLoadingMore || _lastSquawkDoc == null) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final query = await FirebaseFirestore.instance
          .collection('squawks')
          .where('flockId', isEqualTo: widget.flockId)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastSquawkDoc!)
          .limit(_batchSize)
          .get();
      final newSquawks = query.docs.map((doc) {
        final data = doc.data();
        data['docRef'] = doc.reference;
        return data;
      }).toList();
      if (newSquawks.isNotEmpty) {
        setState(() {
          squawks.addAll(newSquawks);
          _lastSquawkDoc = query.docs.last;
          _hasMore = query.docs.length == _batchSize;
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching more squawks: $e");
    }
    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshSquawks() async {
    _lastSquawkDoc = null;
    _hasMore = true;
    await _fetchInitialSquawks();
  }

  Future<void> _toggleFlockNotification(bool value) async {
    final userId = _currentUser?.uid;
    if (userId == null) return;

    setState(() {
      _flockNotificationsEnabled = value;
    });

    final overrideRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notification_settings')
        .doc('flocks')
        .collection(widget.flockId)
        .doc('override');

    await overrideRef
        .set({'notificationsEnabled': value}, SetOptions(merge: true));
  }

  Future<void> _fetchFlockNotificationSetting() async {
    final userId = _currentUser?.uid;
    if (userId == null) return;

    final profileRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notification_settings')
        .doc('profile');

    final overrideSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notification_settings')
        .doc('flocks')
        .collection(widget.flockId)
        .doc('override')
        .get();

    final profileSnap = await profileRef.get();

    final global = profileSnap.data()?['notificationsEnabled'] ?? true;
    final defaultFlock =
        profileSnap.data()?['defaultFlockNotifications'] ?? true;
    final override = overrideSnap.data()?['notificationsEnabled'];

    setState(() {
      _globalNotificationsEnabled = global;
      _flockNotificationsEnabled = global && (override ?? defaultFlock);
      _hasLoadedNotificationSettings = true;
    });
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
        onRefresh: _refreshSquawks,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Neumorphic(
                      style: NeumorphicStyle(
                        depth: 10,
                        intensity: 0.9,
                        surfaceIntensity: 0.1,
                        shape: NeumorphicShape.concave,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(20)),
                        color: const Color(0xFFFFFFFF),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    flockName,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_hasLoadedNotificationSettings)
                                  IconButton(
                                    icon: Icon(
                                        _flockNotificationsEnabled
                                            ? CupertinoIcons.bell_solid
                                            : CupertinoIcons.bell_slash,
                                        color: _flockNotificationsEnabled
                                            ? const Color(0xFFFFCC00)
                                            : CupertinoColors.systemGrey),
                                    tooltip: _flockNotificationsEnabled
                                        ? 'Disable Flock Notifications'
                                        : 'Enable Flock Notifications',
                                    onPressed:
                                        (_hasLoadedNotificationSettings &&
                                                _globalNotificationsEnabled)
                                            ? () => _toggleFlockNotification(
                                                !_flockNotificationsEnabled)
                                            : null,
                                  ),
                              ],
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
                                        maxLines:
                                            _isDescriptionExpanded ? null : 2,
                                        overflow: _isDescriptionExpanded
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: AppColors.mediumGrey),
                                      ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                            if (createdAt != null)
                              Text(
                                "Created on " +
                                    DateFormat('MMMM d, y').format(createdAt!),
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.mediumGrey),
                              ),
                            if (_hasLoadedNotificationSettings &&
                                !_globalNotificationsEnabled)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Enable notifications in settings to receive flock notifications.',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                              ),
                            if (createdBy == _currentUser?.uid &&
                                _hasAccess) ...[
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

                                  final data = snapshot.data!.data()
                                      as Map<String, dynamic>;
                                  final Map<String, dynamic>? requestedUsers =
                                      data['askedToJoin'];

                                  if (requestedUsers == null ||
                                      requestedUsers.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        final username = userInfo['username'] ??
                                            'Unknown User';

                                        return ListTile(
                                          title: Text(username),
                                          subtitle: Text(
                                            "Requested at " +
                                                DateFormat('MMMM d, y hh:mm a')
                                                    .format(
                                                        (userInfo['requestedAt']
                                                                as Timestamp)
                                                            .toDate()),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.check,
                                                    color: Colors.green),
                                                onPressed: () =>
                                                    _approveRequest(
                                                        userId,
                                                        username,
                                                        userInfo[
                                                            'requestedAt']),
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
                                controller: _scrollController,
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount:
                                    squawks.length + (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index < squawks.length) {
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
                                      child: Neumorphic(
                                        style: NeumorphicStyle(
                                          depth: 10,
                                          intensity: 0.9,
                                          surfaceIntensity: 0.1,
                                          shape: NeumorphicShape.concave,
                                          boxShape:
                                              NeumorphicBoxShape.roundRect(
                                                  BorderRadius.circular(20)),
                                          color: const Color(0xFFFFFFFF),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                squawk['title'] ??
                                                    'Untitled Squawk',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                "By " +
                                                    (squawk['username'] ??
                                                        'Unknown User'),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColors.mediumGrey),
                                              ),
                                              if (squawk['mediaUrls'] != null)
                                                _buildMediaPreview(
                                                  List<String>.from(
                                                      squawk['mediaUrls'] ??
                                                          []),
                                                  mediaType:
                                                      squawk['mediaType'],
                                                ),
                                              Text(
                                                squawk['message'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              if (squawk['link'] != null &&
                                                  squawk['link']
                                                      .toString()
                                                      .isNotEmpty)
                                                FutureBuilder<Metadata?>(
                                                  future: MetadataFetch.extract(
                                                      squawk['link']),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData ||
                                                        snapshot.data == null) {
                                                      return const SizedBox();
                                                    }
                                                    final metadata =
                                                        snapshot.data!;
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 12.0),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: AppColors
                                                                .mediumGrey),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (metadata.image !=
                                                              null)
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              child:
                                                                  Image.network(
                                                                metadata.image!,
                                                                height: 150,
                                                                width: double
                                                                    .infinity,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          const SizedBox(
                                                              height: 8),
                                                          if (metadata.title !=
                                                              null)
                                                            Text(
                                                              metadata.title!,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment:
                                                    Alignment.bottomRight,
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
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                },
                              ),
                  ),
                ],
              ),
      ),
    );
  }
}
