import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Color darkGray(Set<MaterialState> states) {
  return const Color(0xFF333333);
}

Color yella(Set<MaterialState> states) {
  return const Color(0xFFFFCC00);
}

class ButtonGroupCalls extends StatefulWidget {
  final String category;
  final String title;
  final String? uid;
  final String? username;

  const ButtonGroupCalls(
      {Key? key,
      required this.category,
      required this.title,
      required this.uid,
      required this.username})
      : super(key: key);
  @override
  _ButtonGroupCallsState createState() => _ButtonGroupCallsState();
}

class _ButtonGroupCallsState extends State<ButtonGroupCalls> {
  late DocumentReference firebaseCat;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  List<bool> isSelected = [true, false, false, false];

  checkCategory() async {
    return setState(
      () {
        firebaseCat = FirebaseFirestore.instance
            .collection('callPreferences')
            .doc(widget.category);
      },
    );
  }

  setIsSelected() async {
    DocumentSnapshot beginnerCheck =
        await firebaseCat.collection('beginner').doc(widget.uid).get();
    DocumentSnapshot advancedCheck =
        await firebaseCat.collection('advanced').doc(widget.uid).get();
    DocumentSnapshot expertCheck =
        await firebaseCat.collection('expert').doc(widget.uid).get();
    beginnerCheck.exists
        ? mounted ? setState(() {
            isSelected[1] = true;
            isSelected[0] = false;
          })
        : null : null;
    advancedCheck.exists
        ? mounted  ? setState(() {
            isSelected[2] = true;
            isSelected[0] = false;
          })
        : null : null;
    expertCheck.exists
        ? mounted ? setState(() {
            isSelected[3] = true;
            isSelected[0] = false;
          })
        : null : null;
  }

  addCategories(index, isSelected) async {
    //check if document exists for each level and check if it is needed. If it exists but isn't needed delete it. If it doesn't exist but needs to, create it. Otherwise, do nothing.
    DocumentSnapshot beginnerCheck =
        await firebaseCat.collection('beginner').doc(widget.uid).get();
    DocumentSnapshot advancedCheck =
        await firebaseCat.collection('advanced').doc(widget.uid).get();
    DocumentSnapshot expertCheck =
        await firebaseCat.collection('expert').doc(widget.uid).get();

    beginnerFuncAdd() async {
      if (beginnerCheck.exists) {
      } else {
        await firebaseCat.collection('beginner').doc(widget.uid).set(
          {'username': widget.username, "uid": widget.uid},
        );
        await messaging.subscribeToTopic("${widget.category}beginner");
      }
    }

    beginnerFuncRemove() async {
      if (beginnerCheck.exists) {
        await firebaseCat.collection('beginner').doc(widget.uid).delete();
        await messaging.unsubscribeFromTopic("${widget.category}beginner");
      }
    }

    advancedFuncAdd() async {
      if (advancedCheck.exists) {
      } else {
        await firebaseCat.collection('advanced').doc(widget.uid).set(
          {'username': widget.username, "uid": widget.uid},
        );
        await messaging.subscribeToTopic("${widget.category}advanced");
      }
    }

    advancedFuncRemove() async {
      if (advancedCheck.exists) {
        await firebaseCat.collection('advanced').doc(widget.uid).delete();
        await messaging.unsubscribeFromTopic("${widget.category}advanced");
      }
    }

    expertFuncAdd() async {
      if (expertCheck.exists) {
      } else {
        await firebaseCat.collection('expert').doc(widget.uid).set(
          {'username': widget.username, "uid": widget.uid},
        );
        await messaging.subscribeToTopic("${widget.category}expert");
      }
    }

    expertFuncRemove() async {
      if (expertCheck.exists) {
        await firebaseCat.collection('expert').doc(widget.uid).delete();
        await messaging.unsubscribeFromTopic("${widget.category}expert");
      }
    }

    isSelected[1] == true ? beginnerFuncAdd() : beginnerFuncRemove();
    isSelected[2] == true ? advancedFuncAdd() : advancedFuncRemove();
    isSelected[3] == true ? expertFuncAdd() : expertFuncRemove();
  }

  removeAll() async {
    await firebaseCat.collection('beginner').doc(widget.uid).delete();
    await firebaseCat.collection('advanced').doc(widget.uid).delete();
    await firebaseCat.collection('expert').doc(widget.uid).delete();
    await messaging.unsubscribeFromTopic("${widget.category}expert");
    await messaging.unsubscribeFromTopic("${widget.category}advanced");
    await messaging.unsubscribeFromTopic("${widget.category}beginner");
  }

  @override
  Widget build(BuildContext context) {
    checkCategory();
    setIsSelected();
    double cWidth = MediaQuery.of(context).size.width * 0.8;

    return SizedBox(
      width: cWidth,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(widget.title, style: const TextStyle(fontSize: 22, fontFamily: 'Nexa'),),
          ),
          ToggleButtons(
            constraints: const BoxConstraints(minWidth: 73, minHeight: 35),
            selectedColor: const Color(0xFF333333),
            color: const Color(0xFF333333),
            fillColor: const Color(0xFFFFCC00),
            focusColor: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(8),
            isSelected: isSelected,
            onPressed: (int index) {
              setState(
                () {
                  if (index != 0) {
                    isSelected[0] = false;
                    isSelected[index] = !isSelected[index];
                  }
                  if (index == 0) {
                    removeAll();
                    isSelected = [true, false, false, false];
                  }
                },
              );
              addCategories(index, isSelected);
            },
            children: const <Widget>[
              Text('None'),
              Text('Beginner'),
              Text('Advanced'),
              Text('Expert'),
            ],
          ),
        ],
      ),
    );
  }
}
