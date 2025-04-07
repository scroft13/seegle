import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:seegle/screens/flock_details.dart';
import 'package:seegle/store/store.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/widgets/add_flock_button.dart';
import 'package:seegle/widgets/new_squawk_button.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String flockId;

  const CustomAppBar({super.key, required this.flockId});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(56.0); // ✅ Implemented correctly
}

class _CustomAppBarState extends State<CustomAppBar> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _allFlocks = [];
  List<QueryDocumentSnapshot> _filteredFlocks = [];
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _fetchFlocks();
    _searchController.addListener(() {
      _onSearchChanged();
    });
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce!.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        _filterFlocks(_searchController.text);
      }
    });
  }

  Future<void> _fetchFlocks() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('flocks').get();
    setState(() {
      _allFlocks = snapshot.docs;
      _filteredFlocks = _allFlocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 44,
      leading: Row(
        children: [
          Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () =>
                      Navigator.canPop(context) ? Navigator.pop(context) : null)
              : SizedBox(
                  width: 20,
                ),
          const Text(
            'Seegle',
            style: TextStyle(
              fontSize: 26,
              color: Colors.black,
              fontFamily: 'NexaLight',
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            height: 32,
            child: Image.asset('assets/icons/icon.png', height: 32),
          ),
        ],
      ),
      leadingWidth: 200,
      actions: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6.0, right: 12),
          child:
              Navigator.canPop(context) ? NewSquawkButton() : AddFlockButton(),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: IconButton(
            onPressed: _openBottomSheet,
            icon: const Icon(Icons.search_sharp),
            color: Colors.black,
            iconSize: 28,
          ),
        ),
      ],
    );
  }

  void _filterFlocks(String query) {
    setState(() {
      _filteredFlocks = _allFlocks.where((flock) {
        final name = (flock['flockName'] ?? '').toLowerCase();
        final description = (flock['description'] ?? '').toLowerCase();
        final uniqueFlockName = (flock['uniqueFlockName'] ?? '').toLowerCase();
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            uniqueFlockName.contains(searchQuery);
      }).toList();
    });
  }

  void _navigateToFlock(String flockId) {
    Provider.of<AppStore>(context, listen: false).setFlockId(flockId);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlockDetailsScreen(
          flockId: flockId,
        ),
      ),
    );
  }

  void _openBottomSheet() async {
    if (!context.mounted) return;
    final BuildContext localContext = context;
    await _fetchFlocks();
    if (!context.mounted) return;
    if (!localContext.mounted) return;
    showModalBottomSheet(
      context: localContext,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            double maxHeight = MediaQuery.of(context).size.height * 0.9;

            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search Flocks',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (query) {
                          setModalState(() {
                            _filterFlocks(query);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredFlocks.length,
                        itemBuilder: (context, index) {
                          final flock = _filteredFlocks[index];
                          final flockName =
                              flock['flockName'] ?? 'Unknown Flock';
                          final normalizedName = flock['uniqueFlockName'] ?? '';
                          final description =
                              flock['description'] ?? 'No details available';

                          return ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    flockName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      normalizedName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.mediumGrey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mediumGrey,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () => _navigateToFlock(flock.id),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
