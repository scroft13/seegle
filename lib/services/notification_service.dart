import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> shouldNotifyUserForFlock(String userId, String flockId) async {
  final firestore = FirebaseFirestore.instance;

  final profileSnap = await firestore
      .collection('users')
      .doc(userId)
      .collection('notification_settings')
      .doc('profile')
      .get();

  final overrideSnap = await firestore
      .collection('users')
      .doc(userId)
      .collection('notification_settings')
      .doc('flocks')
      .collection(flockId)
      .doc('override')
      .get();

  final global = profileSnap.data()?['notificationsEnabled'] ?? true;
  final defaultFlock = profileSnap.data()?['defaultFlockNotifications'] ?? true;
  final override = overrideSnap.data()?['notificationsEnabled'];

  return global && (override ?? defaultFlock);
}

class NotificationService {
  static Future<bool> shouldNotifyUserForFlock(
      String userId, String flockId) async {
    final firestore = FirebaseFirestore.instance;

    final profileSnap = await firestore
        .collection('users')
        .doc(userId)
        .collection('notification_settings')
        .doc('profile')
        .get();

    final overrideSnap = await firestore
        .collection('users')
        .doc(userId)
        .collection('notification_settings')
        .doc('flocks')
        .collection(flockId)
        .doc('override')
        .get();

    final global = profileSnap.data()?['notificationsEnabled'] ?? true;
    final defaultFlock =
        profileSnap.data()?['defaultFlockNotifications'] ?? true;
    final override = overrideSnap.data()?['notificationsEnabled'];

    return global && (override ?? defaultFlock);
  }

  static Future<void> setGlobalNotificationsEnabled(
      String userId, bool enabled) async {
    final firestore = FirebaseFirestore.instance;
    await firestore
        .collection('users')
        .doc(userId)
        .collection('notification_settings')
        .doc('profile')
        .set({'notificationsEnabled': enabled}, SetOptions(merge: true));
  }
}
