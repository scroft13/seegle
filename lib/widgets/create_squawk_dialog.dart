import 'package:flutter/material.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/widgets/new_squawk_option.dart';
import 'package:seegle/widgets/video_recorder.dart';

class NewSquawkDialog extends StatefulWidget {
  const NewSquawkDialog({super.key});

  @override
  State<NewSquawkDialog> createState() => _NewSquawkDialogState();
}

class _NewSquawkDialogState extends State<NewSquawkDialog> {
  double offset = 0;
  final _titleController = TextEditingController();

  void setOffset(number) {
    var offsetSize = (number - 170) / 2;
    setState(() {
      offset = offsetSize;
    });
  }

  Future<void> _createNewSquawk(context) async {
    try {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoRecorderWidget(
            title: _titleController.text,
          ),
        ),
      );
    } catch (e) {
      print("Error adding squawk: $e");
      Navigator.of(context).pop();
    }
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
                const NewDialogOption(
                  icon: Icons.message_outlined,
                  title: 'New Squawk',
                  subTitle: 'Send out a new squawk for help',
                ),
                Form(
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'What is your squawk message?',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: TextField(
                          controller: _titleController,
                          onEditingComplete: () {},
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                    onPressed: () => {_createNewSquawk(context)},
                    child: const Text('Send Squawk'))
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
      ],
    );
  }
}
