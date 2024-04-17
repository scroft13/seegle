import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:seegle/screens/auth/auth_wrapper.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';
import 'package:url_launcher/url_launcher.dart';

class DeleteAccount extends StatelessWidget {
  const DeleteAccount({Key? key}) : super(key: key);
  // static FirebaseAnalytics analytics = FirebaseAnalytics();
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);
  final _url = 'https://youtu.be/dQw4w9WgXcQ';
  void _easterEggTime() async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
  Route _delete(BuildContext context) {
    void confirmed() async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.id)
          .delete();
      await FirebaseFirestore.instance
          .collection('squawks')
          .doc(currentUser!.id)
          .delete();
      await FirebaseFirestore.instance
          .collection('usernames')
          .doc(currentUser!.username.toLowerCase())
          .delete();
      await FirebaseAuth.instance.signOut();

      // Get.offAll(() => AuthWrapper(analytics: analytics, observer: observer));
    }

    return CupertinoModalPopupRoute(
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Are you sure you want to do this?',
              style: TextStyle(fontSize: 24)),
          message: SelectableLinkify(
            text:
                'For real, I cry a little bit inside whenever someone deletes their account. If there\'s something we can do better please don\'t hesitate to contact us at seegleapp@gmail.com. With that being said, if you still want to go, we won\'t stop you. We\'re not Scientology.',
            style: const TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            onOpen: (link) async {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch $link';
              }
            },
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: ConfirmationSlider(
                backgroundColor: const Color(0xFF333333),
                foregroundColor: const Color(0xFFFFCC00),
                iconColor: const Color(0xFF333333),
                text: 'Slide To Delete',
                textStyle: const TextStyle(color: Color(0xFFB2B2B2)),
                onConfirmation: () => confirmed(),
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
    return TextButton(
      child: const Text('Delete Account'),
      onPressed: () {
        Navigator.of(context).push(_delete(context));
      },
      onLongPress: () {
        _easterEggTime();
      },
    );
  }
}
