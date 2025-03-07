import 'package:flutter/material.dart';
import 'package:seegle/styles.dart';

class NewDialogOption extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  const NewDialogOption(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 70,
              child: Icon(icon),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subTitle,
                  style: const TextStyle(
                    color: AppColors.mediumGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          color: AppColors.lightGrey,
          height: .25,
        )
      ],
    );
  }
}
