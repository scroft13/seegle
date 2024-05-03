import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:seegle/screens/home_screen.dart';
import 'package:seegle/models/user_model.dart';
import 'package:seegle/screens/username_registration_screen.dart';
import 'package:seegle/user_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle(context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _firebaseAuth.signInWithCredential(credential);
        await _postSignInProcess(_firebaseAuth.currentUser, context);
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      throw Exception('Google Sign-In Failed');
    }
  }

  Future<void> signInWithApple(context) async {
    try {
      final appleCredential =
          await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);
      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await _firebaseAuth.signInWithCredential(credential);
      await _postSignInProcess(_firebaseAuth.currentUser, context);
    } catch (e) {
      print('Apple Sign-In Error: $e');
      throw Exception('Apple Sign-In Failed');
    }
  }

  Future<void> _postSignInProcess(User? user, context) async {
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists || userDoc.data()!['username'] == null) {
        // User is new or doesn't have a username
        UserModel userModel = UserModel(uid: user.uid, email: user.email!);

        // Provider.of<UserProvider>(context, listen: false).setUser(userModel);
        // print(userModel);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UsernameRegistrationScreen(user: userModel),
          ),
        );
      }

      // Redirect to Username Registration Screen
      // This redirection could be handled by a callback or a Navigator push depending on your app's architecture
      else {
        Provider.of<UserProvider>(context, listen: false).setUser(user.uid);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
        // Existing user with username
        // Proceed to home or main screen
      }
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    final result = await _firestore.collection('usernames').doc(username).get();
    return !result.exists;
  }

  Future<void> setUsername(String username, UserModel user) async {
    await _firestore.collection('usernames').doc(username).set({
      'userId': user.uid,
    });
    await _firestore.collection('users').doc(user.uid).set({
      'username': username,
      'email': user.email,
      'internetPoints': user.internetPoints ?? 0,
      'photoUrl': user.photoUrl,
      'uid': user.uid
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut(); // Ensure Google sign-out
    // Apple sign-out handled implicitly with Firebase sign-out
  }
}
