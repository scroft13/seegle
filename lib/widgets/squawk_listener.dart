import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/widgets/profile_pic.dart';

class SquawkListWidget extends StatelessWidget {
  const SquawkListWidget({super.key});

  String formatLocalDateTime(Timestamp timestamp) {
    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
    var formatter = DateFormat.yMd().add_jm(); // Date and time format
    return formatter
        .format(dateTime.toLocal()); // Convert to local time and format
  }

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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 50,
                          width: 50,
                          child: ProfilePictureWidget(
                              photoUrl: data['photoUrl'] ?? '')),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data['username'],
                                  style: const TextStyle(
                                    color: AppColors.darkGrey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  formatLocalDateTime(data['timestamp']),
                                  style: const TextStyle(
                                    color: AppColors.lightGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              data['title'],
                              style: const TextStyle(
                                color: AppColors.lightGrey,
                                fontSize: 13,
                              ),
                              maxLines: 2, // Maximum number of lines to show
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
