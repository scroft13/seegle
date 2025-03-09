import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seegle/screens/home_screen.dart';
import 'package:seegle/screens/profile_screen.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/widgets/add_flock_button.dart';
import 'package:seegle/widgets/app_bar.dart';
import 'package:seegle/widgets/bottom_bar.dart';
import 'package:seegle/widgets/flockDetails.dart';

final squawkRef = FirebaseFirestore.instance.collection('groupNotification');

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({
    super.key,
  });

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Function to navigate to the flock details screen
  void _navigateToFlockDetails(String flockId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlockDetailsScreen(
          flockId: flockId,
          pageIndex: _pageIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: SafeArea(
              child: IndexedStack(
                index: _pageIndex,
                children: <Widget>[
                  HomeScreen(
                    onFlockTap:
                        _navigateToFlockDetails, // Pass the function to handle tap
                  ),
                  const ProfilePage(),
                ],
              ),
            ),
          ),
          Container(
            height: .25,
            color: AppColors.lightGrey,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
