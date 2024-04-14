import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math'; // Import dart:math for Random

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> _checkUserExists(User user) async {
    // Attempt to get the user document by UID
    var doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists;
  }

  // Google Sign-In
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Sign out first to ensure the account picker is shown each time
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Proceed to sign in with Firebase
      return await _signInWithCredential(credential);
    } catch (error) {
      print('Failed to sign in with Google: $error');
      throw error;
    }
  }

  // Apple Sign-In
  Future<UserCredential> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    return _signInWithCredential(oauthCredential);
  }

  // Helper method for handling credentials
  Future<UserCredential> _signInWithCredential(
      OAuthCredential credential) async {
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final User? user = userCredential.user;

    bool userExists = await _checkUserExists(user!);
    if (!userExists) {
      _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        'creationTime': user.metadata.creationTime?.toIso8601String(),
      });
    }

    return userCredential;
  }

  // Utilities
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
