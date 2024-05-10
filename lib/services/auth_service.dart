import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:seegle/home_wrapper.dart';
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
        await postSignInProcess(_firebaseAuth.currentUser, context);
      }
    } catch (e) {
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
      await postSignInProcess(_firebaseAuth.currentUser, context);
    } catch (e) {
      throw Exception('Apple Sign-In Failed');
    }
  }

  Future<void> postSignInProcess(User? user, context) async {
    print(user);
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists || userDoc.data()!['username'] == null) {
        // User is new or doesn't have a username
        UserModel userModel = UserModel(
            uid: user.uid,
            email: user.email!,
            photoUrl: user.photoURL,
            isBanned: false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UsernameRegistrationScreen(user: userModel),
          ),
        );
      } else {
        // Existing user with username
        // Proceed to home or main screen
        Provider.of<UserProvider>(context, listen: false).clearUser();

        Provider.of<UserProvider>(context, listen: false).setUser(user.uid);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const HomeWrapper(),
          ),
        );
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
      'uid': user.uid,
      'isBanned': false
    }, SetOptions(merge: true));
  }

  Future<void> signOut(context) async {
    await _firebaseAuth.signOut();

    Provider.of<UserProvider>(context, listen: false).clearUser();
    await GoogleSignIn().signOut();
    Navigator.of(context).popAndPushNamed('/');
    // Ensure Google sign-out
    // Apple sign-out handled implicitly with Firebase sign-out
  }
}
