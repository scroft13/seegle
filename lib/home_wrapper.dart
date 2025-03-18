import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:seegle/screens/private_screen.dart';
import 'package:seegle/screens/public_screen.dart';
import 'package:seegle/screens/profile_screen.dart';
import 'package:seegle/store/store.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/widgets/app_bar.dart';
import 'package:seegle/widgets/bottom_bar.dart';
import 'package:seegle/screens/flock_details.dart';

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
  String? flockId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToFlockDetails(String flockId) {
    Provider.of<AppStore>(context, listen: false).setFlockId(flockId);
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: false,
        builder: (context) => FlockDetailsScreen(
          flockId: flockId,
        ),
      ),
    );
  }

  void printNavStack(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(flockId: flockId ?? ''),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: SafeArea(
              child: IndexedStack(
                index: _pageIndex,
                children: <Widget>[
                  PublicScreen(
                    onFlockTap: _navigateToFlockDetails,
                  ),
                  PrivateScreen(
                    onFlockTap: _navigateToFlockDetails,
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
