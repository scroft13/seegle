import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../styles.dart';
import 'auth_wrapper.dart';

class UpdateUsername extends StatelessWidget {
  UpdateUsername({Key? key}) : super(key: key);
  // static FirebaseAnalytics analytics = FirebaseAnalytics();
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);

  final usernameController = TextEditingController();
  final usernameRef = FirebaseFirestore.instance.collection('usernames');

  // final String username = "";

  _updateUsername(context) async {
    var usernamecheck = usernameController.text;
    var usernameCheckLowercase = usernamecheck.toLowerCase();
    DocumentSnapshot usernameCheck =
        await usernameRef.doc(usernameCheckLowercase).get();

    if (usernamecheck.length < 3 ||
        usernamecheck.length > 24 ||
        usernamecheck.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Your username is either too short or too long. We need it juuust right.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Allrightey Then.')),
            ],
          );
        },
      );
    } else if (usernameCheck.exists) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Sorry, that username already exists.'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Allrightey Then.')),
            ],
          );
        },
      );
    } else if (usernamecheck.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text('Did you forget something?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Allrightey Then.')),
            ],
          );
        },
      );
    } else {
      usernameRef.doc(currentUser!.username.toLowerCase()).delete();
      usernameRef
          .doc(usernameCheckLowercase)
          .set({"username": usernamecheck, "id": currentUser!.id});
      usersRef.doc(currentUser!.id).update({'username': usernamecheck});
      Fluttertoast.showToast(
        msg: '$usernamecheck it shall be from now on.',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: const Color(0xFFFFCC00),
        textColor: const Color(0xFF333333),
        timeInSecForIosWeb: 2,
      );
      Timer(const Duration(seconds: 2), () {
        // Get.to(() => AuthWrapper(
        //       analytics: analytics,
        //       observer: observer,
        //     ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'What should we call you now?',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: TextField(
                controller: usernameController,
                onEditingComplete: () {},
                style: Styles.subTitle,
                decoration: InputDecoration(
                  focusColor: const Color(0xFFFFCC00),
                  hoverColor: const Color(0xFFFFCC00),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  fillColor: const Color(0xFFFFFFFF),
                ),
              ),
            ),
            const Expanded(
              child: Text(''),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: FloatingActionButton.extended(
                label: const Text('Update'),
                onPressed: () {
                  _updateUsername(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child:
                  TextButton(onPressed: Get.back, child: const Text('Cancel')),
            )
          ],
        ),
      ),
    );
  }
}
