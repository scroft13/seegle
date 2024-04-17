import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:seegle/models/call.dart';
import '/seegle_icons.dart';
import 'advisory_check.dart';
import 'auth/auth_wrapper.dart';
import 'call screens/call_screen.dart';
import 'squawks.dart';
import 'profile.dart';

final squawkRef = FirebaseFirestore.instance.collection('groupNotification');

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({
    Key? key,
  }) : super(key: key);

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

  // _squawkCheck(docId, channel) async {
  //   DocumentSnapshot docCheck = await squawkRef.doc(docId).get();

  //   if (docCheck.exists) {
  //     squawkRef.doc(docId).delete();
  //     Get.to(
  //       () => JoinChannelVideo(
  //         channelId: docId,
  //         call: Call(),
  //         needsSquawkLink: false,
  //         answeringReturnedCall: false,
  //         isHero: true,
  //         isSquawker: false,
  //       ),
  //     );
  //   } else {
  //     Fluttertoast.showToast(
  //       msg:
  //           'Thanks for trying to help, but another Seegler is already on the case!',
  //       toastLength: Toast.LENGTH_LONG,
  //       backgroundColor: const Color(0xFFFFCC00),
  //       textColor: const Color(0xFF333333),
  //       timeInSecForIosWeb: 2,
  //     );
  //   }
  // }

  @override
  void initState() {
    messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        message.data["channel"] == currentUser?.username
            ? null
            : ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 6666),
                  content: Text(
                    message.notification!.body.toString(),
                    style: const TextStyle(color: Color(0xFF666666)),
                    semanticsLabel: message.notification!.body.toString(),
                  ),
                  backgroundColor: const Color(0xFFFFCC00),
                  action: SnackBarAction(
                    label: 'Answer Call',
                    textColor: const Color(0xFF333333),
                    onPressed: () {
                      // if (message.data["call_type"] == "group") {
                      //   _squawkCheck(message.data["delete_doc_of"],
                      //       message.data["channel"]);
                      // } else if (message.data["call_type"] == "return_squawk") {
                      //   FirebaseFirestore.instance
                      //       .collection('squawks')
                      //       .doc(currentUser!.id)
                      //       .delete();
                      //   Get.to(
                      //     () => JoinChannelVideo(
                      //       channelId: message.data["channel"],
                      //       call: Call(),
                      //       needsSquawkLink: false,
                      //       answeringReturnedCall: true,
                      //       isHero: false,
                      //       isSquawker: true,
                      //     ),
                      //   );
                      // } else {
                      Get.offAll(const HomeWrapper());
                      // }
                    },
                  ),
                ),
              );
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data["call_type"] == "group") {
        //   _squawkCheck(message.data["delete_doc_of"], message.data["channel"]);
        // } else if (message.data["call_type"] == "return_squawk") {
        //   FirebaseFirestore.instance
        //       .collection('squawks')
        //       .doc(currentUser!.id)
        //       .delete();
        //   Get.to(
        //     () => JoinChannelVideo(
        //       channelId: message.data["channel"],
        //       call: Call(),
        //       needsSquawkLink: false,
        //       answeringReturnedCall: true,
        //       isHero: false,
        //       isSquawker: true,
        //     ),
        //   );
        // } else {
        Get.offAll(const HomeWrapper());
      }
    });

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
            AdvisoryCheck(),
            Squawks(),
            ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Seegle.seegle),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Seegle.hero),
            label: 'Squawks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Seegle.winston),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFFFFCC00),
        backgroundColor: const Color(0xFF333333),
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
