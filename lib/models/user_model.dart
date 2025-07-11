class UserModel {
  String uid;
  String email;
  bool isBanned;
  String? username;
  String? photoUrl;
  int? internetPoints;

  UserModel(
      {required this.uid,
      required this.email,
      required this.isBanned,
      this.username,
      this.internetPoints,
      this.photoUrl});

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'internetPoints': internetPoints ?? 0,
      'isBanned': isBanned
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        uid: json['uid'],
        email: json['email'],
        isBanned: json['isBanned'],
        username: json['username'] ?? '',
        photoUrl: json['photoUrl'] ?? '',
        internetPoints: json['internetPoints'] ?? 0);
  }
}
