// import 'dart:convert';
// import 'dart:developer' as developer;
// import 'dart:math';

// import 'package:crypto/crypto.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import '../../styles.dart';
// import '../home_wrapper.dart';
// import '/models/user.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../screens/auth/sign_up.dart';

// final GoogleSignIn googleSignIn = GoogleSignIn();
// final usersRef = FirebaseFirestore.instance.collection('users');
// final usernameRef = FirebaseFirestore.instance.collection('usernames');
// final DateTime timestamp = DateTime.now();
// CustomUser? currentUser;
// const String versionNumber = "1.3.0";

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({
//     Key? key,
//     required this.analytics,
//     required this.observer,
//   }) : super(key: key);
//   final FirebaseAnalytics analytics;
//   final FirebaseAnalyticsObserver observer;

//   @override
//   _AuthWrapperState createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   bool isAuth = false;
//   bool showAppleLogin = true;
//   bool _error = false;
//   late String errorMessage;

//   initializeFlutterFire() async {
//     try {
//       await Firebase.initializeApp();
//     } catch (e) {
//       setState(() {
//         _error = true;
//       });
//       setState(() {
//         errorMessage = e.toString();
//       });
//     }
//     try {
//       FirebaseAuth.instance.currentUser != null
//           ? handleSignIn(FirebaseAuth.instance.currentUser)
//           : null;
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//       });
//     }
//   }

//   @override
//   void initState() {
//     initializeFlutterFire();
//     widget.analytics.setAnalyticsCollectionEnabled(true);
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       setState(() {
//         // showAppleLogin = false;
//       });
//     }
//     super.initState();
//   }

//   String generateNonce([int length = 32]) {
//     const charset =
//         '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
//     final random = Random.secure();
//     return List.generate(length, (_) => charset[random.nextInt(charset.length)])
//         .join();
//   }

//   String sha256ofString(String input) {
//     final bytes = utf8.encode(input);
//     final digest = sha256.convert(bytes);
//     return digest.toString();
//   }

//   _appleLogin() async {
//     // To prevent replay attacks with the credential returned from Apple, we
//     // include a nonce in the credential request. When signing in with
//     // Firebase, the nonce in the id token returned by Apple, is expected to
//     // match the sha256 hash of `rawNonce`.
//     final rawNonce = generateNonce();
//     final nonce = sha256ofString(rawNonce);
//     // Request credential for the currently signed in Apple account.
//     final appleCredential = await SignInWithApple.getAppleIDCredential(
//       scopes: [
//         AppleIDAuthorizationScopes.email,
//         AppleIDAuthorizationScopes.fullName,
//       ],
//       nonce: nonce,
//     );
//     // Create an `OAuthCredential` from the credential returned by Apple.
//     final oauthCredential = OAuthProvider("apple.com").credential(
//       idToken: appleCredential.identityToken,
//       rawNonce: rawNonce,
//     );
//     // Sign in the user with Firebase. If the nonce we generated earlier does
//     // not match the nonce in `appleCredential.identityToken`, sign in will fail.
//     await FirebaseAuth.instance.signInWithCredential(oauthCredential);
//     User? user = FirebaseAuth.instance.currentUser;
//     handleSignIn(user);
//   }

//   googleLogin() async {
//     // Trigger the authentication flow
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//     // Obtain the auth details from the request
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser!.authentication;

//     // Create a new credential
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     // Once signed in, return the UserCredential
//     await FirebaseAuth.instance.signInWithCredential(credential);
//     User? user = FirebaseAuth.instance.currentUser;
//     handleSignIn(user);
//   }

//   handleSignIn(User? user) async {
//     if (user != null) {
//       await createUserInFirestore(user);
//       setState(() {
//         isAuth = true;
//       });
//     } else {
//       setState(() {
//         isAuth = false;
//       });
//     }
//   }

//   createUserInFirestore(User user) async {
//     DocumentSnapshot users = await usersRef.doc(user.uid).get();
//     if (!users.exists) {
//       String username = await Navigator.push(
//           context, MaterialPageRoute(builder: (context) => const SignUp()));
//       String usernameLowercase = username.toLowerCase();
//       usernameRef
//           .doc(usernameLowercase)
//           .set({"username": username, "id": user.uid});
//       usersRef.doc(user.uid).set(
//         {
//           "id": user.uid,
//           "username": username,
//           "photoUrl": user.photoURL,
//           "email": user.email,
//           "timestamp": timestamp,
//           "cannabisSeegleRating": 0,
//           "cannabisSelfRating": 0,
//           "cookingSeegleRating": 0,
//           "mushroomsSeegleRating": 0,
//           "mushroomsSelfRating": 0,
//           "cookingSelfRating": 0,
//           "isAdmin": false,
//           "internetPoints": 100,
//         },
//       );
//       users = await usersRef.doc(user.uid).get();
//       setState(() {
//         isAuth = true;
//       });
//     }
//   }

//   Scaffold unAuthScreen(context) {
//     double cWidth = MediaQuery.of(context).size.width * 0.8;

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
//         alignment: Alignment.center,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: showAppleLogin == true
//               ? <Widget>[
//                   Image(
//                     width: cWidth,
//                     image: const AssetImage(
//                         'assets/icon/seegle_logo_with_words.png'),
//                     semanticLabel: "Seegle Icon",
//                   ),
//                   Column(
//                     children: [
//                       const Text(
//                         'Welcome to Seegle!',
//                         style: Styles.categoryText,
//                         textAlign: TextAlign.center,
//                       ),
//                       const Padding(
//                           padding: EdgeInsets.all(12.0),
//                           child: Text(
//                             'Please signup or login with the providers below',
//                             style: Styles.subTitle,
//                             textAlign: TextAlign.center,
//                           )),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Semantics(
//                           label: "Apple Login Button",
//                           child: GestureDetector(
//                             onTap: () {
//                               _appleLogin();
//                             },
//                             child: Container(
//                               width: 260,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(5),
//                                 image: const DecorationImage(
//                                   image: AssetImage(
//                                       'assets/sign_in/apple-id-sign-in-with_2x.png'),
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Semantics(
//                           label: "Google Login Button",
//                           child: GestureDetector(
//                             onTap: () {
//                               googleLogin();
//                             },
//                             child: Container(
//                               width: 260,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(5),
//                                 image: const DecorationImage(
//                                   image: AssetImage(
//                                       'assets/sign_in/google_signin_button.png'),
//                                   fit: BoxFit.fill,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Text(
//                     "Version $versionNumber",
//                     textAlign: TextAlign.center,
//                   ),
//                 ]
//               : <Widget>[
//                   Image(
//                     width: cWidth,
//                     image: const AssetImage(
//                         'assets/icon/seegle_logo_with_words.png'),
//                     semanticLabel: "Seegle Icon",
//                   ),
//                   Column(
//                     children: [
//                       const Text(
//                         'Welcome to Seegle!',
//                         style: Styles.categoryText,
//                         textAlign: TextAlign.center,
//                       ),
//                       const Padding(
//                           padding: EdgeInsets.all(12.0),
//                           child: Text(
//                             'Please signup or login with the providers below',
//                             style: Styles.subTitle,
//                             textAlign: TextAlign.center,
//                           )),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Semantics(
//                           label: "Google Login Button",
//                           child: GestureDetector(
//                             onTap: () {
//                               googleLogin();
//                             },
//                             child: Container(
//                               width: 260,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(5),
//                                 image: const DecorationImage(
//                                   image: AssetImage(
//                                       'assets/sign_in/google_signin_button.png'),
//                                   fit: BoxFit.fill,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Text(
//                     "Version $versionNumber",
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_error) {
//       developer.log(errorMessage);
//     }

//     return isAuth ? const HomeWrapper() : unAuthScreen(context);
//   }
// }
