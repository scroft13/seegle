import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:seegle/screens/home_screen.dart';
import 'package:seegle/screens/profile.dart';
import '/seegle_icons.dart';

final squawkRef = FirebaseFirestore.instance.collection('groupNotification');

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({
    super.key,
  });

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  _saveDeviceToken() async {
    final String id = FirebaseAuth.instance.currentUser!.uid.toString();
    String? messagingToken = await messaging.getToken();
    if (messagingToken != null) {
      var tokens = _db.collection('users').doc(id).collection('tokens');
      await tokens.doc(id).set(
        {
          'token': messagingToken,
          'createdAt': FieldValue.serverTimestamp(), // optional
          'platform': Platform.operatingSystem, // optional
        },
      );
    }
  }

  @override
  void initState() {
    _saveDeviceToken();
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
      body: SafeArea(
        child: IndexedStack(
          index: _pageIndex,
          children: const <Widget>[
            HomeScreen(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        fixedColor: const Color(0xFFFFCC00),
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Seegle.hero),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Seegle.winston),
            label: 'Profile',
          )
        ],
        // selectedItemColor: const Color(0xFFFFCC00),
        backgroundColor: const Color(0xFFFFFFFF),
        selectedFontSize: 18,
        unselectedItemColor: const Color(0xFFB2B2B2),
        selectedIconTheme: const IconThemeData(size: 45),
        enableFeedback: true,
        selectedLabelStyle:
            const TextStyle(leadingDistribution: TextLeadingDistribution.even),
        currentIndex: _pageIndex,
        onTap: (int index) {
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
