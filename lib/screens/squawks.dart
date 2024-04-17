import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seegle/models/call_user.dart';
import 'package:seegle/resources/call_utilities.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';
import '../styles.dart';
import 'auth/auth_wrapper.dart';

class Squawks extends StatefulWidget {
  const Squawks({Key? key}) : super(key: key);

  @override
  State<Squawks> createState() => _SquawksState();
}

class _SquawksState extends State<Squawks> {
  //get list of subscribed categories
  String? uid = currentUser?.id;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
  }

  static Route _modalBuilder(
      BuildContext context,
      String message,
      String category,
      String subcategory,
      String squawkerUsername,
      String squawkerId) {
    return CupertinoModalPopupRoute(
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title:
              const Text('Getting Ready to Seegle', style: Styles.categoryText),
          message: Column(
            children: [
              const Text(
                'We\'re getting ready to connect you with a fellow Seegler',
                style: TextStyle(fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            subcategory,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Text('Are you sure you want to continue?',
                  style: TextStyle(fontSize: 18))
            ],
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: ConfirmationSlider(
                backgroundColor: const Color(0xFF333333),
                foregroundColor: const Color(0xFFFFCC00),
                iconColor: const Color(0xFF333333),
                text: 'Slide To Seegle',
                textStyle: const TextStyle(color: Color(0xFFB2B2B2)),
                onConfirmation: () {
                  Navigator.pop(context);
                  CallUtils.dial(
                      from: CallUser(
                          id: currentUser!.id, username: currentUser!.username),
                      to: CallUser(id: squawkerId, username: squawkerUsername),
                      context: context);
                },
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
        body: Center(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('squawks').orderBy('timestamp', descending: false).snapshots(),
        builder: (context, AsyncSnapshot<dynamic> streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final documents = streamSnapshot.data!.docs;
          return documents.length > 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) => SizedBox(
                      width: cWidth,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            _modalBuilder(
                                context,
                                documents[index]['message'],
                                documents[index]['category'],
                                documents[index]['subcategory'],
                                documents[index]['username'],
                                documents[index]['uid']),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          color: const Color(0xFF333333),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  documents[index]['username'] + ' Needs Help!',
                                  style:
                                      const TextStyle(color: Color(0xFFFFCC00)),
                                ),
                              ),
                              Container(
                                width: cWidth,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xFFFFFFFF)),
                                margin:
                                    const EdgeInsets.fromLTRB(15, 0, 15, 15),
                                child: Column(
                                  children: [
                                    Text(
                                      'Category: ' +
                                          documents[index]['category'],
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Subcategory: ' +
                                          documents[index]['subcategory'],
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const Center(
                  child: Text('It\'s all quiet for now'),
                );
        },
      ),
    ));
  }
}
