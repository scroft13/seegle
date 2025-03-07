import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seegle/styles.dart';
import '../services/auth_service.dart';

// ignore: must_be_immutable
class AuthScreen extends StatefulWidget {
  bool shouldShowScaffold;
  AuthScreen({super.key, required this.shouldShowScaffold});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool showAppleLogin = true;
  final AuthService _authService = AuthService();
  bool isLoggedIn = false;
  @override
  void initState() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      setState(() {
        showAppleLogin = false;
      });
    }
    isLoggedIn = FirebaseAuth.instance.currentUser != null;
    if (isLoggedIn) {
      widget.shouldShowScaffold = true;
      handleLogin(context);
    }
    super.initState();
  }

  handleLogin(context) async {
    // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    await _authService.postSignInProcess(
        FirebaseAuth.instance.currentUser, context);
  }

  Scaffold unauthScreen(context) {
    const String versionNumber = "1.3.0";
    double cWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: showAppleLogin == true
              ? <Widget>[
                  Image(
                    width: cWidth,
                    image: const AssetImage(
                        'assets/icon/seegle_logo_with_words.png'),
                    semanticLabel: "Seegle Icon",
                  ),
                  Column(
                    children: [
                      const Text(
                        'Welcome to Seegle!',
                        style: Styles.categoryText,
                        textAlign: TextAlign.center,
                      ),
                      const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Please signup or login with the providers below',
                            style: Styles.subTitle,
                            textAlign: TextAlign.center,
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Semantics(
                          label: "Apple Login Button",
                          child: GestureDetector(
                            onTap: () {
                              _authService.signInWithApple(context);
                            },
                            child: Container(
                              width: 260,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/sign_in/apple-id-sign-in-with_2x.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Semantics(
                          label: "Google Login Button",
                          child: GestureDetector(
                            onTap: () {
                              _authService.signInWithGoogle(context);
                            },
                            child: Container(
                              width: 260,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/sign_in/google_signin_button.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Version $versionNumber",
                    textAlign: TextAlign.center,
                  ),
                ]
              : <Widget>[
                  Image(
                    width: cWidth,
                    image: const AssetImage(
                        'assets/icon/seegle_logo_with_words.png'),
                    semanticLabel: "Seegle Icon",
                  ),
                  Column(
                    children: [
                      const Text(
                        'Welcome to Seegle!',
                        style: Styles.categoryText,
                        textAlign: TextAlign.center,
                      ),
                      const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Please signup or login with the providers below',
                            style: Styles.subTitle,
                            textAlign: TextAlign.center,
                          )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Semantics(
                          label: "Google Login Button",
                          child: GestureDetector(
                            onTap: () {
                              _authService.signInWithGoogle(context);
                            },
                            child: Container(
                              width: 260,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: const DecorationImage(
                                  image: AssetImage(
                                      'assets/sign_in/google_signin_button.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Version $versionNumber",
                    textAlign: TextAlign.center,
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return unauthScreen(context);
  }
}
