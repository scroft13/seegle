import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:seegle/screens/auth/auth_wrapper.dart';
import '../../styles.dart';
import '../report_user.dart';

class PostCall extends StatefulWidget {
  final String heroId;
  final String squawkerId;
  final bool isHero;
  final bool isSquawker;
  final String heroName;
  final String squawkerName;
  final String channelId;
  const PostCall({
    Key? key,
    required this.heroId,
    required this.squawkerId,
    required this.isHero,
    required this.isSquawker,
    required this.heroName,
    required this.squawkerName,
    required this.channelId,
  }) : super(key: key);

  @override
  _PostCallState createState() => _PostCallState();
}

class _PostCallState extends State<PostCall> {
  //set default values to 5
  int _currentHeroValue = 5;
  int _currentSquawkerValue = 5;
  int _currentSeegleSliderValue = 5;

  String _label = "0";
  // static FirebaseAnalytics analytics = FirebaseAnalytics();
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);

  _sendFeedback(
    double pointsSquawker,
    double pointsHero,
    double pointsSeegle,
  ) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    if (widget.heroId == FirebaseAuth.instance.currentUser!.uid) {
      late double squawkerPointsAfter;
      DocumentSnapshot snapshot = await usersRef.doc(widget.squawkerId).get();

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        squawkerPointsAfter = data['internetPoints'] + pointsHero;
      });
      usersRef.doc(widget.squawkerId).update(
        {'internetPoints': squawkerPointsAfter},
      );
    } else {
      late double heroPointsAfter;
      DocumentSnapshot snapshot = await usersRef.doc(widget.heroId).get();

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        heroPointsAfter = data['internetPoints'] + pointsHero.toDouble();
      });
      usersRef.doc(widget.heroId).update(
        {'internetPoints': heroPointsAfter},
      );
    }
    await Fluttertoast.showToast(
      msg: 'Thank you for your feedback!',
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: const Color(0xFFFFCC00),
      textColor: const Color(0xFF333333),
      timeInSecForIosWeb: 2,
    );
    // Get.to(() => AuthWrapper(analytics: analytics, observer: observer));
    final CollectionReference callDoc =
        FirebaseFirestore.instance.collection("callDoc");
    callDoc.doc(widget.channelId).delete();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double cHeight = MediaQuery.of(context).size.height * 0.95;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: cHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8.0, 50, 8, 0),
                child: Text(
                  "How was your experience?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "Nexa", fontSize: 24),
                ),
              ),
              Column(
                children: [
                  widget.isHero
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "How was your call with ${widget.squawkerName}?",
                            style: Styles.postCallBodyText,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Was your question answered?",
                            style: Styles.postCallBodyText,
                            textAlign: TextAlign.center,
                          ),
                        ),
                  widget.isHero
                      ? const Text("")
                      : Text(
                          "You can award ${widget.heroName} up to five Internet Points.",
                          style: Styles.postCallBodyText,
                          textAlign: TextAlign.center,
                        ),
                  widget.isHero
                      ? Slider(
                          value: _currentSquawkerValue.toDouble(),
                          min: 0,
                          max: 5,
                          divisions: 6,
                          label: _currentSquawkerValue.toString(),
                          onChanged: (double value) {
                            setState(
                              () {
                                _currentSquawkerValue = value.toInt();
                              },
                            );
                          },
                        )
                      : Slider(
                          value: _currentHeroValue.toDouble(),
                          min: 0,
                          max: 5,
                          divisions: 6,
                          label: _currentHeroValue.toString(),
                          onChanged: (double value) {
                            setState(
                              () {
                                _currentHeroValue = value.toInt();
                              },
                            );
                          },
                        ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "How did Seegle do? Was your call quality acceptable?",
                    style: Styles.postCallBodyText,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 12),
                    child: Text(
                      "You can give Seegle up to five Internet Points, or tell us to eat a bag of dicks.",
                      style: Styles.postCallBodyText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Slider(
                    value: _currentSeegleSliderValue.toDouble(),
                    min: -1,
                    max: 5,
                    divisions: 6,
                    label: _label,
                    onChanged: (double value) {
                      value >= 0
                          ? setState(
                              () {
                                _currentSeegleSliderValue = value.toInt();
                                _label = _currentSeegleSliderValue.toString();
                              },
                            )
                          : setState(
                              () {
                                _currentSeegleSliderValue = value.toInt();
                                _label = "Eat a bag of dicks Seegle!";
                              },
                            );
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  widget.isHero
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xff666666),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 38.0, vertical: 5),
                              child: Column(
                                children: [
                                  Text(
                                    "The award bestowed upon",
                                    style: Styles.postCallBodyText,
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      widget.squawkerName,
                                      style: Styles.postCallBodyText,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Text(
                                    "shall be $_currentSquawkerValue Internet Points",
                                    style: Styles.postCallBodyText,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xff666666),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 38.0, vertical: 5),
                            child: Column(
                              children: [
                                Text(
                                  "The award bestowed upon",
                                  style: Styles.postCallBodyText,
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget.heroName,
                                    style: Styles.postCallBodyText,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Text(
                                  "shall be $_currentHeroValue Internet Points",
                                  style: Styles.postCallBodyText,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                  _currentSeegleSliderValue < 0
                      ? Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Text(
                            "Eat a Bag of Dicks Seegle!",
                            style: Styles.postCallBodyTextRed,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xff666666),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 38.0, vertical: 5),
                              child: Column(
                                children: [
                                  Text(
                                    "The award bestowed upon",
                                    style: Styles.postCallBodyText,
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Seegle",
                                      style: Styles.postCallBodyText,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Text(
                                    "shall be $_currentSeegleSliderValue Internet Points",
                                    style: Styles.postCallBodyText,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ],
              ),
              FloatingActionButton.extended(
                heroTag: "Send Feedback",
                onPressed: () async {
                  await _sendFeedback(
                    _currentSquawkerValue.toDouble(),
                    _currentHeroValue.toDouble(),
                    _currentSeegleSliderValue.toDouble(),
                  );
                },
                label: const Text(
                  "Send Feedback",
                ),
              ),
              FloatingActionButton.extended(
                heroTag: "Report User",
                onPressed: () {
                  widget.isHero
                      ? Get.to(() => ReportUser(
                            reportingId: widget.heroId,
                            reportedId: widget.squawkerId,
                          ))
                      : Get.to(() => ReportUser(
                            reportingId: widget.squawkerId,
                            reportedId: widget.heroId,
                          ));
                },
                label: const Text(
                  "Report User",
                ),
                backgroundColor: const Color(0xffFF0000),
                foregroundColor: const Color(0xffFFFFFF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
