import 'package:cloud_firestore/cloud_firestore.dart';

class CallUser {
  final String id;
  final String username;

  CallUser({
    required this.id,
    required this.username,
  });

  factory CallUser.fromDocument(DocumentSnapshot doc) {
    return CallUser(
      id: doc['id'],
      username: doc['username'],
    );
  }
}
