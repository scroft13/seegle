import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/screens/auth/auth_wrapper.dart';
import '/screens/home_wrapper.dart';
import '/seegle_icons.dart';
import '../../styles.dart';

class NoAnswer extends StatefulWidget {
  final String dbCategory;
  final String subcategory;
  final String label;
  const NoAnswer(
      {Key? key,
      required this.dbCategory,
      required this.label,
      required this.subcategory})
      : super(key: key);

  @override
  _NoAnswerState createState() => _NoAnswerState();
}

class _NoAnswerState extends State<NoAnswer> {
  late String message;
  dynamic _selection;
  int _time = 172800000;

  final squawkController = TextEditingController();
  final squaksRef = FirebaseFirestore.instance.collection('squawks');

  _setMessage() {
    setState(() {
      message = squawkController.text;
    });
  }

  _submit() {
    setState(() {
      message = squawkController.text;
    });

    squaksRef.doc(currentUser!.id).set(
      {
        'message': message,
        "uid": currentUser!.id,
        'category': widget.label,
        'subcategory': widget.subcategory,
        'username': currentUser!.username,
        'seconds': _time
      },
    );
    Get.offAll(
      () => const HomeWrapper(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 55, 10, 0),
                child: Text(
                  'Sorry we couldn\'t get to your question.',
                  style: Styles.categoryText,
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Text(
                  'Leave a Squawk and a Seegler will try and connect with you shortly.',
                  style: Styles.subTitle,
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: Text('Category:', style: Styles.categoryText),
                  ),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: Styles.subTitle,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5.0),
                    child: Text('SubCategory:', style: Styles.categoryText),
                  ),
                  Text(
                    widget.subcategory,
                    textAlign: TextAlign.center,
                    style: Styles.subTitle,
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'Leave a Brief Message:',
                    style: Styles.subTitle,
                  ),
                  Form(
                    autovalidateMode: AutovalidateMode.always,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: TextField(
                        minLines: 3,
                        maxLines: 4,
                        controller: squawkController,
                        onEditingComplete: _setMessage(),
                        style: Styles.subTitle,
                        decoration: const InputDecoration(
                          fillColor: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "This Squawk will self-destruct in :",
                      style: Styles.subTitle,
                    ),
                  ),
                  PopupMenuButton(
                    child: Container(
                      // width: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: const Color(0xFFFF0000),
                          border: Border.all(
                              color: const Color(0xFFFF0000),
                              width: 2,
                              style: BorderStyle.solid)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selection == null
                                  ? "48 Hours"
                                  : _selection.toString(),
                              style: const TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 20,
                                  fontFamily: 'Nexa'),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 58.0),
                              child: Icon(
                                Icons.arrow_drop_down_circle_outlined,
                                color: Color(0xFFFFFFFF),
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onSelected: (value) {
                      if (value == '15 Minutes') {
                        setState(
                          () {
                            _selection = value;
                            _time = 900000;
                          },
                        );
                      } else if (value == "1 Hour") {
                        setState(
                          () {
                            _selection = value;
                            _time = 3600000;
                          },
                        );
                      } else if (value == "4 Hours") {
                        setState(
                          () {
                            _selection = value;
                            _time = 14400000;
                          },
                        );
                      } else if (value == "8 Hours") {
                        setState(
                          () {
                            _selection = value;
                            _time = 28800000;
                          },
                        );
                      } else if (value == "24 Hours") {
                        setState(
                          () {
                            _selection = value;
                            _time = 86400000;
                          },
                        );
                      } else if (value == "48 Hours") {
                        setState(
                          () {
                            _selection = value;
                            _time = 172800000;
                          },
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: '15 Minutes',
                        child: Text('15 Minutes'),
                      ),
                      const PopupMenuItem(
                        value: '1 Hour',
                        child: Text('1 Hour'),
                      ),
                      const PopupMenuItem(
                        value: '4 Hours',
                        child: Text('4 Hours'),
                      ),
                      const PopupMenuItem(
                        value: '8 Hours',
                        child: Text('8 Hours'),
                      ),
                      const PopupMenuItem(
                        value: '24 Hours',
                        child: Text('24 Hours'),
                      ),
                      const PopupMenuItem(
                        value: '48 Hours',
                        child: Text('48 Hours'),
                      ),
                    ],
                  ),
                ],
              ),
              FloatingActionButton.extended(
                onPressed: _submit,
                label: const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Squawk',
                    style: TextStyle(
                        color: Color(0xFF333333),
                        fontFamily: 'Nexa',
                        fontSize: 26),
                  ),
                ),
                icon: const Icon(
                  Seegle.squawkIcon,
                  size: 40,
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.offAll(
                    () => const HomeWrapper(),
                  );
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
