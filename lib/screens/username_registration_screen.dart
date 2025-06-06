import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:seegle/home_wrapper.dart';
import 'package:seegle/models/user_model.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';

class UsernameRegistrationScreen extends StatefulWidget {
  const UsernameRegistrationScreen({
    super.key,
    required this.user,
  });
  final UserModel user;

  @override
  UsernameRegistrationScreenState createState() =>
      UsernameRegistrationScreenState();
}

class UsernameRegistrationScreenState
    extends State<UsernameRegistrationScreen> {
  final _usernameController = TextEditingController();
  bool _isProcessing = false;
  bool _agree = false;
  String? username;
  final usernameRef = FirebaseFirestore.instance.collection('usernames');

  final AuthService _authService = AuthService();
  Future<void> _launchURLPrivacy() async {
    Uri link = Uri.parse("https://seegle.app/privacy");
    if (await canLaunchUrl(link)) {
      await launchUrl(link);
    } else {
      throw 'Could not launch $link';
    }
  }

  Future<void> _launchURLTerms() async {
    const link = "https://seegle.app/terms";
    Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $link';
    }
  }

  Future<void> submitUsername() async {
    final AuthService authService = AuthService();
    username = _usernameController.text;
    var usernameCheckLowercase = username?.toLowerCase();
    DocumentSnapshot usernameCheck =
        await usernameRef.doc(usernameCheckLowercase).get();
    if (_agree == false) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
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
      await authService.setUsername(_usernameController.text, widget.user);
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).clearUser();
      Provider.of<UserProvider>(context, listen: false)
          .setUser(widget.user.uid);

      Fluttertoast.showToast(
        msg: 'Welcome $username! We are excited to have you!',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: const Color(0xFFFFCC00),
        textColor: const Color(0xFF333333),
        timeInSecForIosWeb: 2,
      );
      Timer(const Duration(milliseconds: 100), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeWrapper()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 55.0),
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
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'We just need some basic info before we can get started',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Form(
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'What should we call you?',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: TextField(
                      controller: _usernameController,
                      onEditingComplete: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Switch(
                    onChanged: (bool value) {
                      setState(() {
                        _agree = value;
                      });
                    },
                    value: _agree,
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          child: Text(
                            'Are you at least 13 years old and do you agree to what our team (not legally a team) of legal advisers has told us you have to agree to in order to use the app?',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: CupertinoButton(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkGrey,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      _isProcessing ? 'Processing...' : 'Let\'s Go!',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isProcessing = true;
                  });
                  submitUsername();
                  setState(() {
                    _isProcessing = false;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _authService.signOut(context);
              },
              child: const Text('Cancel'),
            )
          ],
        ),
      ),
    );
  }
}
