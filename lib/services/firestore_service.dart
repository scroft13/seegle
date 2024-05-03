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
        print("Document does not exist");
        onDataChanged({});
      }
    }, onError: (error) {
      print("Error listening to document: $error");
    });
  }
}
