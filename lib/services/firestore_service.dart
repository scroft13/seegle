import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void listenToDocument(String collectionPath, String documentId,
      Function(Map<String, dynamic> data) onDataChanged) {
    _firestore.collection(collectionPath).doc(documentId).snapshots().listen(
        (snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        onDataChanged(snapshot.data() as Map<String, dynamic>);
      } else {
        onDataChanged({});

        throw Exception('Document does not exist');
      }
    }, onError: (error) {
      throw Exception("Error listening to document: $error");
    });
  }
}
