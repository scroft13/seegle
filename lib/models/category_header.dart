import 'package:flutter/cupertino.dart';

import '../styles.dart';

class CategoryHeader extends StatelessWidget {
  final String text;
  final String label;
  const CategoryHeader({Key? key, required this.text, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                label,
                style: Styles.categoryText,
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  text,
                  style: Styles.subTitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ]));
  }
}
