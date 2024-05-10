import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seegle/screens/home_screen.dart';
import 'package:seegle/screens/profile_screen.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/widgets/bottom_bar.dart';

final squawkRef = FirebaseFirestore.instance.collection('groupNotification');

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({
    super.key,
  });

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            child: SafeArea(
              child: IndexedStack(
                index: _pageIndex,
                children: const <Widget>[
                  HomeScreen(),
                  // SquawkListWidget(),
                  ProfilePage(),
                ],
              ),
            ),
          ),
          Container(
            height: .25,
            color: AppColors.lightGrey,
          )
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTap: (index) {
          setState(
            () {
              _pageIndex = index;
            },
          );
        },
      ),
    );
  }
}
