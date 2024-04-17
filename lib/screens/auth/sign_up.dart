import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:seegle/screens/auth/auth_wrapper.dart';
import '/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final usernameRef = FirebaseFirestore.instance.collection('usernames');

  String? username;
  var _agree = false;
  final usernameController = TextEditingController();
  bool validated = false;

 
  submit() async {
    username = usernameController.text;
    var usernameCheckLowercase = username?.toLowerCase();
    DocumentSnapshot usernameCheck =
        await usernameRef.doc(usernameCheckLowercase).get();
    if (_agree == false) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Error'),
            content: const Text(
                'You must agree to our terms if you want to continue.'),
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
    } else if (username!.length < 3 ||
        username!.length > 24 ||
        username!.isEmpty) {
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
    } else {
      Fluttertoast.showToast(
        msg: 'Welcome $username! We are excited to have you!',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: const Color(0xFFFFCC00),
        textColor: const Color(0xFF333333),
        timeInSecForIosWeb: 2,
      );
      Timer(const Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  Future<void> _launchURLPrivacy() async {
    const link = "https://seegle.app/privacy";
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch $link';
    }
  }

  Future<void> _launchURLTerms() async {
    const link = "https://seegle.app/terms";
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch $link';
    }
  }

  @override
  Scaffold build(BuildContext context) {
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    double cHeight = MediaQuery.of(context).size.height * 0.9;
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: cHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 55.0),
                child: SizedBox(
                  height: 97,
                  width: 327,
                  child: Stack(
                    children: <Widget>[
                      Text(
                        'Welcome To Seegle!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 45,
                          fontFamily: "Nexa",
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1.6
                            ..color = const Color.fromARGB(255, 66, 66, 66),
                          letterSpacing: 4.5,
                        ),
                      ),
                      const Text(
                        'Welcome To Seegle!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 45,
                          fontFamily: "Nexa",
                          color: Color.fromARGB(255, 255, 204, 0),
                          letterSpacing: 4.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                'We just need some basic info before we can get started',
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              Form(
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'What should we call you?',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: TextField(
                        controller: usernameController,
                        onEditingComplete: () {},
                        
                        style: Styles.subTitle,
                        
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoSwitch(
                      onChanged: (bool value) {
                        setState(() {
                          _agree = value;
                        });
                      },
                      value: _agree,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: cWidth,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agree = !_agree;
                              });
                            },
                            child: const Text(
                              'Are you at least 13 years old and do you agree to what our team (not legally a team) of legal advisers has told us you have to agree to in order to use the app? TLDR; Don\'t be a dick, don\'t show your dick.',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              softWrap: true,
                              textWidthBasis: TextWidthBasis.parent,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: cWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: _launchURLPrivacy,
                                child: const Text('Privacy Policy'),
                              ),
                              TextButton(
                                  onPressed: _launchURLTerms,
                                  child: const Text('Terms of Agreement'))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: submit,
                    child: Container(
                      width: 300,
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xFF333333),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Let\'s Go!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFCC00),
                            fontSize: 48,
                            fontFamily: 'Nexa Bold',
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      googleSignIn.signOut();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
