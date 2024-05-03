import 'package:flutter/material.dart';
import 'package:seegle/services/firestore_service.dart';
import 'models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  void setUser(String userId) async {
    UserModel userData;
    FirestoreService().listenToDocument('users', userId, (data) {
      userData = UserModel.fromJson(data);
      _user = userData;
      notifyListeners();
      print('notified');
    });
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void changeUser(
    UserModel user,
  ) async {
    _user = user;
    notifyListeners();
  }
}
