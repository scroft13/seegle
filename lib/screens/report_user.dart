import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../styles.dart';
import 'auth/auth_wrapper.dart';

class ReportUser extends StatefulWidget {
  final String reportingId;
  final String reportedId;
  const ReportUser(
      {Key? key, required this.reportedId, required this.reportingId})
      : super(key: key);

  @override
  _ReportUserState createState() => _ReportUserState();
}

class _ReportUserState extends State<ReportUser> {
  // static FirebaseAnalytics analytics = FirebaseAnalytics();
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);
  final messageController = TextEditingController();
  _fileReport() async {
    final reportRef = FirebaseFirestore.instance.collection('reports');

    DocumentSnapshot snapshot = await reportRef.doc(widget.reportedId).get();
    if (snapshot.exists) {
      late int reportCount;
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        reportCount = data['report_count'] + 1;
      });
      reportRef.doc(widget.reportedId).update(
        {
          'reporting_user_id_$reportCount':
              FirebaseAuth.instance.currentUser!.uid,
          'message_$reportCount': messageController.text,
          'timestamp_$reportCount': timestamp,
          'report_count': reportCount
        },
      );
    } else {
      reportRef.doc(widget.reportedId).set(
        {
          'report_count': 1,
          'reporting_user_id_1': FirebaseAuth.instance.currentUser!.uid,
          'message_1': messageController.text,
          'timestamp_1': timestamp
        },
      );
    }
    Fluttertoast.showToast(
      msg: 'Thank you for your report!',
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: const Color(0xFFFFCC00),
      textColor: const Color(0xFF333333),
      timeInSecForIosWeb: 2,
    );
    // Timer(const Duration(seconds: 2), () {
    //   Get.to(() => AuthWrapper(analytics: analytics, observer: observer));
    // });
  }

  @override
  Scaffold build(BuildContext context) {
    double cHeight = MediaQuery.of(context).size.height * 0.9;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: cHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Report User",
                style: TextStyle(
                  color: Color(0xffFF0000),
                  fontSize: 36,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 25),
                child: Text(
                  "We are sorry you had a shit experience. Tell us about it, and upon review the user will either be warned or banned.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontFamily: "Nexa"),
                ),
              ),
              Form(
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'What happened?',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: TextField(
                        controller: messageController,
                        onEditingComplete: () {},
                        style: Styles.subTitle,
                        minLines: 4,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              FloatingActionButton.extended(
                onPressed: _fileReport,
                label: const Text("Submit",
                    style: TextStyle(color: Color(0xffFFFFFF), fontSize: 20)),
                backgroundColor: const Color(0xffFF0000),
              ),
              const SizedBox(
                height: 50,
              ),
              TextButton(
                onPressed: () {
                  Get.to(() => {}
                      // AuthWrapper(analytics: analytics, observer: observer));
                      );
                },
                child: const Text(
                  "CANCEL",
                  style: TextStyle(fontSize: 18),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
