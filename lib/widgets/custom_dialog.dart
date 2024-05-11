import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/widgets/create_squawk_dialog.dart';
import 'package:seegle/widgets/new_squawk_option.dart';

class MyCustomDialog extends StatefulWidget {
  const MyCustomDialog({super.key});

  @override
  State<MyCustomDialog> createState() => _MyCustomDialogState();
}

class _MyCustomDialogState extends State<MyCustomDialog> {
  bool addGoogleBottomMargin = true;
  double offset = 0;

  @override
  void initState() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      setState(() {
        addGoogleBottomMargin = false;
      });
    }

    super.initState();
  }

  void setOffset(number) {
    var offsetSize = (number - 170) / 2;
    setState(() {
      offset = offsetSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    setOffset(screenWidth);
    return Column(
      children: [
        Expanded(
          child: Container(),
        ),
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            width: screenWidth - 25,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                GestureDetector(
                  child: const NewDialogOption(
                    icon: Icons.message_outlined,
                    title: 'New Squawk',
                    subTitle: 'Send out a new squawk for help',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return const NewSquawkDialog();
                      },
                    );
                  },
                ),
                const NewDialogOption(
                  icon: Icons.people_outline_sharp,
                  title: 'New Community',
                  subTitle: 'Create a new community to post squawks',
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          child: Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            insetPadding: EdgeInsets.only(left: offset, right: offset),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.darkGrey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        SizedBox(
          height: addGoogleBottomMargin ? 0 : 33,
        )
      ],
    );
  }
}
