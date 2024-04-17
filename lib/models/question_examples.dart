import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../styles.dart';

// ignore: must_be_immutable
class QuestionExamples extends StatelessWidget {
  String category;
  List questionsAvoid;
  List questionsBeginner;
  List questionsAdvanced;
  List questionsExpert;

  QuestionExamples(
      {Key? key,
      required this.category,
      required this.questionsAdvanced,
      required this.questionsExpert,
      required this.questionsBeginner,
      required this.questionsAvoid})
      : super(key: key);

  static Route _modalBuilder(
      BuildContext context,
      String category,
      List questionsAvoid,
      List questionsArrayBeginner,
      List questionsArrayAdvanced,
      List questionsArrayExpert) {
    return CupertinoModalPopupRoute(
      barrierDismissible: true,
      builder: (BuildContext context) {
        double cWidth = MediaQuery.of(context).size.width * 0.8;
        return CupertinoActionSheet(
          title: const Text(
            'Not sure where your question falls?',
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          message: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                width: cWidth,
                decoration: BoxDecoration(color: const Color(0xFFFFCC00), borderRadius: BorderRadiusDirectional.circular(8)),
                child: const Text(
                  'Please don\'t ask generic questions like:',
                  style: Styles.questionCategory,
                ),
              ),
              Column(
                children: questionsAvoid
                    .map((question) =>
                        Text(question + '?', style: Styles.questionText))
                    .toList(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                width: cWidth,
                decoration: BoxDecoration(color: const Color(0xFFFFCC00), borderRadius: BorderRadiusDirectional.circular(8)),
                child: const Text(
                  'Beginner questions: ',
                  style: Styles.questionCategory,
                ),
              ),
              Column(
                children: questionsArrayBeginner
                    .map((question) =>
                        Text(question + '?', style: Styles.questionText))
                    .toList(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                width: cWidth,
                decoration: BoxDecoration(color: const Color(0xFFFFCC00), borderRadius: BorderRadiusDirectional.circular(8)),
                child: const Text(
                  'Advanced questions: ',
                  style: Styles.questionCategory,
                ),
              ),
              Column(
                children: questionsArrayAdvanced
                    .map((question) =>
                        Text(question + '?', style: Styles.questionText))
                    .toList(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
                width: cWidth,
                decoration: BoxDecoration(color: const Color(0xFFFFCC00), borderRadius: BorderRadiusDirectional.circular(8)),
                child: const Text(
                  'Expert questions: ',
                  style: Styles.questionCategory,
                ),
              ),
              Column(
                children: questionsArrayExpert
                    .map((question) =>
                        Text(question + '?', style: Styles.questionText))
                    .toList(),
              ),
            ],
          ),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: TextButton(
                child: const Text(
                  'Dismiss',
                  style: TextStyle(color: Color(0xFFD1A804), fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 45.0),
      child: FloatingActionButton.extended(
        label: const Text('Not sure where your question falls?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF333333),
              fontFamily: 'Nexa',
              fontSize: 14,
            )),
       
        onPressed: () {
          Navigator.of(context).push(_modalBuilder(
              context,
              category,
              questionsAvoid,
              questionsBeginner,
              questionsAdvanced,
              questionsExpert));
        },
      ),
    );
  }
}
