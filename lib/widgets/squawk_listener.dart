import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SquawkListWidget extends StatelessWidget {
  const SquawkListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Firestore reference to the squawks collection
    final Stream<QuerySnapshot> squawksStream =
        FirebaseFirestore.instance.collection('squawks').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: squawksStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            return ListTile(
              title: Text(data['title'] ??
                  'No content'), // Assuming 'content' is the field for the squawk text
              subtitle: Text(data['username'] ??
                  'Anonymous'), // Assuming 'username' is the field for the username
            );
          }).toList(),
        );
      },
    );
  }
}
