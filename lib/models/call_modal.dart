import 'package:flutter/cupertino.dart';
import 'package:seegle/resources/call_utilities.dart';
import 'package:seegle/screens/auth/auth_wrapper.dart';
import 'package:slide_to_confirm/slide_to_confirm.dart';

import '../styles.dart';
import 'call_user.dart';

class CallModal extends StatelessWidget {
  final String subcategory;
  final String label;
  final String dbCategory;
  const CallModal(
      {Key? key,
      required this.subcategory,
      required this.dbCategory,
      required this.label})
      : super(key: key);

  static Route _modalBuilder(BuildContext context, String dbCategory,
      String label, String subcategory) {
    void confirmed() {
      CallUtils.groupDial(
        from: CallUser(id: currentUser!.id, username: currentUser!.username),
        topic: dbCategory + subcategory.toLowerCase(),
        dbCategory: dbCategory,
        subcategory: subcategory,
        label: label,
      );
    }

    return CupertinoModalPopupRoute(
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title:
              const Text('Getting Ready to Seegle', style: Styles.categoryText),
          message: Column(
            children: [
              const Text(
                'We\'re getting ready to connect you with a fellow Seegler',
                style: TextStyle(fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text('$label\n$subcategory',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Text('Are you sure you want to continue?',
                  style: TextStyle(fontSize: 18))
            ],
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: ConfirmationSlider(
                backgroundColor: const Color(0xFF333333),
                foregroundColor: const Color(0xFFFFCC00),
                iconColor: const Color(0xFF333333),
                text: 'Slide To Seegle',
                textStyle: const TextStyle(color: Color(0xFFB2B2B2)),
                onConfirmation: () => confirmed(),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(_modalBuilder(context, dbCategory, label, subcategory));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
        child: Container(
          width: 300,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              subcategory,
              style: const TextStyle(
                  color: Color(0xFFFFCC00), fontSize: 18, fontFamily: 'Nexa'),
            ),
          ),
        ),
      ),
    );
  }
}
