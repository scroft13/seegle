import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';
import 'package:seegle/models/call.dart';
import 'package:seegle/resources/call_methods.dart';
import 'package:flutter/material.dart';
import 'package:seegle/screens/auth/auth_wrapper.dart';

import 'no_answer.dart';

class RingingScreen extends StatefulWidget {
  final bool needsSquawkLink;
  final bool answeringReturnedCall;
  final Call call;
  final String? label;
  final String? dbCategory;
  final String? subcategory;
  const RingingScreen(
      {Key? key,
      required this.needsSquawkLink,
      required this.answeringReturnedCall,
      required this.call,
      this.label,
      this.subcategory,
      this.dbCategory})
      : super(key: key);

  @override
  _RingingScreenState createState() => _RingingScreenState();
}

class _RingingScreenState extends State<RingingScreen> {
  final CallMethods callMethods = CallMethods();
  // static FirebaseAnalytics analytics = FirebaseAnalytics();
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);
  bool timeWentOff = false;
  @override
  void initState() {
    super.initState();
    _squawkText();
  }

  _squawkText() {
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        // check whether the state object is in tree
        setState(() {
          timeWentOff = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
              "Thanks for using Seegle! Please wait while we connect you.",
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center),
          const CircularProgressIndicator(),
          timeWentOff == false
              ? const Text("")
              : widget.needsSquawkLink == true
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        callMethods.endCall(call: widget.call);
                        Get.offAll(
                          () => NoAnswer(
                            dbCategory: widget.dbCategory.toString(),
                            label: widget.label.toString(),
                            subcategory: widget.subcategory.toString(),
                          ),
                        );
                      },
                      label: const Text(
                        "No Answer? Leave a Squawk!",
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: widget.answeringReturnedCall
                              ? const Text(
                                  "It looks like something went wrong. Whomever was here has probably left. Please try again.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                )
                              : const Text(
                                  "It doesn't look like anyone is answering."),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: FloatingActionButton.extended(
                              onPressed: () {
                                callMethods.endCall(call: widget.call);
                                // Get.offAll(() => AuthWrapper(
                                //       analytics: analytics,
                                //       observer: observer,
                                //     ));
                              },
                              label: const Text("Go Home")),
                        ),
                      ],
                    )
        ],
      ),
    );
  }
}
