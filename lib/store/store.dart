import 'package:flutter/material.dart';

class AppStore extends ChangeNotifier {
  String _flockId = '';

  String get flockId => _flockId;

  void setFlockId(String id) {
    _flockId = id;
    notifyListeners();
  }
}
