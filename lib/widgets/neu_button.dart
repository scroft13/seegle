import 'package:flutter/material.dart';
import 'package:seegle/styles.dart';

class NeumorphicButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const NeumorphicButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-3, -3),
                  blurRadius: 8,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white10,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                buttonText,
                style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'NexaBold'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
