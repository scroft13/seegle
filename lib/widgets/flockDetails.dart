import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/widgets/bottom_bar.dart';

class FlockDetailsScreen extends StatefulWidget {
  final String flockId;
  num pageIndex;

  FlockDetailsScreen(
      {super.key, required this.flockId, required this.pageIndex});

  @override
  _FlockDetailsScreenState createState() => _FlockDetailsScreenState();
}

class _FlockDetailsScreenState extends State<FlockDetailsScreen> {
  bool _isExpanded = false; // Track the expanded state of the description
  String flockName = ''; // Flock name variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 44,
        leading: SizedBox(
          height: 44,
          child: Row(
            children: [
              if (Navigator.canPop(context))
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

              // Use Expanded to allow the text to adjust its width

              const Text(
                'Seegle',
                style: TextStyle(
                  fontSize: 30,
                  color: AppColors.darkGrey,
                  fontFamily: 'NexaLight',
                ),
              ),

              Column(
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 40,
                    height: 30,
                    child: Image.asset('assets/icon/icon.png', height: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
        leadingWidth: 209,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              onPressed: () => {},
              icon: const Icon(Icons.search_sharp),
              color: AppColors.mediumGrey,
              iconSize: 32,
            ),
          ),
        ],
      ),
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

          // Use post-frame callback to update the flockName
          if (flockName.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                flockName = data['flockName'] ??
                    "Unnamed Flock"; // Set flockName from Firestore data
              });
            });
          }

          // Limit the description to two lines and toggle expand/collapse
          String descriptionToDisplay = description.length > 100
              ? _isExpanded
                  ? description
                  : '${description.substring(0, 100)}...'
              : description;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(flockName,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
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
                  Text("Squawks: ${squawks.length}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTap: (index) {
          setState(() {
            widget.pageIndex = index;
          });
        },
      ),
    );
  }
}
