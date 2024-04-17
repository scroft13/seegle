import 'package:flutter/material.dart';

class VoteCategory extends StatelessWidget {
  final String id;
  final String title;
  const VoteCategory({Key? key, required this.id, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
        child: Container(
          width: 300,
          height: 50,
          decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                  color: Color(0xFFFFCC00), fontSize: 18, fontFamily: 'Nexa'),
            ),
          ),
        ),
      ),
    );
  }
}
