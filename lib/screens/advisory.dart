import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:seegle/screens/home_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class Advisory extends StatefulWidget {
  const Advisory({Key? key}) : super(key: key);

  @override
  State<Advisory> createState() => _AdvisoryState();
}

class _AdvisoryState extends State<Advisory> {
  setSeenAdivsory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seenAdvisory', true);
  }

  @override
  Widget build(BuildContext context)  {
    return  Scaffold(
      backgroundColor: const Color(0xff666666),
      body: CupertinoActionSheet(
        title: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC00),
            borderRadius: BorderRadiusDirectional.circular(8),
          ),
          child: const Text(
            'PLEASE BE ADVISED',
            style: TextStyle(
              fontSize: 26,
              color: Color(0xFF666666),
            ),
          ),
        ),
        message: Column(
          children: [
            // ignore: avoid_unnecessary_containers
            Container(
              child: const Text(
                  'Seegle facilitates video conversations between strangers. We help to connect one person with a question, to another with an answer. To honour your privacy, these conversations are not monitored or recorded by Seegle in any way, shape, or form. As such, Seegle cannot be held responsible for what transpires within these conversations, either verbally or visually. The content of what a user decides to say or share represents only the user themselves; their content and speech is theirs alone, and in no way represents the opinions or motivations of us at Seegle. Do not use Seegle to break the law, encourage harmful behaviours, or harass other users. You alone are responsible for knowing and understanding the applicable laws in your region, and for treating other users with empathy. Peace and love, always.\n-  Seegle LLC',
                  style: TextStyle(fontSize: 16)
                  // style: Styles.questionCategory,
                  ),
            ),
          ],
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: TextButton(
              child: const Text(
                'Accept',
                style: TextStyle(color: Color(0xff333333), fontSize: 20),
              ),
              onPressed: () => {
                setSeenAdivsory(),
                Get.to(
                  const HomeWrapper(),
                ),
              },
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
