import 'dart:ffi';

class UserModel {
  String uid;
  String email;
  String? username;
  String? photoUrl;
  int? internetPoints;

  UserModel(
      {required this.uid,
      required this.email,
      this.username,
      this.internetPoints,
      this.photoUrl});

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'internetPoints': internetPoints ?? 0
    };
  }

  // Factory constructor to create a UserModel from a map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        uid: json['uid'],
        email: json['email'],
        username: json['username'] ?? '', // Handle null if necessary
        photoUrl: json['photoUrl'] ?? '',
        internetPoints: json['internetPoints'] ?? 0);
  }
}
