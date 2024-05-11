import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(
        // title: Text('Seegle'),
        backgroundColor: Colors.white,
        toolbarHeight: 44,
        leading: SizedBox(
          height: 44,
          child: Row(
            children: [
              const SizedBox(
                width: 28,
              ),
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
                  const SizedBox(
                    height: 8,
                  ),
                  SizedBox(
                    width: 40,
                    height: 30,
                    child: Image.asset(
                      'assets/icon/icon.png',
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        leadingWidth: 184,
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
