import 'package:cloud_firestore/cloud_firestore.dart';

class CustomUser {
  final String id;
  final String username;
  final String? photoUrl;
  final String email;
  final int cannabisSelfRating;
  final int cannabisSeegleRating;
  final int mushroomsSelfRating;
  final int mushroomsSeegleRating;
  final int cookingSelfRating;
  final int cookingSeegleRating;
  final bool isAdmin;
  final int internetPoints;

  CustomUser({
    required this.id,
    required this.username,
    required this.photoUrl,
    required this.email,
    required this.cannabisSeegleRating,
    required this.cannabisSelfRating,
    required this.cookingSeegleRating,
    required this.mushroomsSeegleRating,
    required this.mushroomsSelfRating,
    required this.cookingSelfRating,
    required this.isAdmin,
    required this.internetPoints
  });

  factory CustomUser.fromDocument(DocumentSnapshot doc) {
    return CustomUser(
      id: doc['id'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      username: doc['username'],
      cannabisSeegleRating: doc['cannabisSeegleRating'].toInt(),
      cannabisSelfRating: doc['cannabisSelfRating'].toInt(),
      cookingSeegleRating: doc['cookingSeegleRating'].toInt(),
      mushroomsSeegleRating: doc['mushroomsSeegleRating'].toInt(),
      mushroomsSelfRating: doc['mushroomsSelfRating'].toInt(),
      cookingSelfRating: doc['cookingSelfRating'].toInt(),
      isAdmin: doc['isAdmin'],
      internetPoints: doc['internetPoints'].toInt()
    );
  }
}
