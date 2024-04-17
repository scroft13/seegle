import 'package:flutter/material.dart';

class Category extends StatelessWidget {
  final String label;
  final Widget title;
  const Category({Key? key, required this.label, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => title));
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
              label,
              style: const TextStyle(
                  color: Color(0xFFFFCC00), fontSize: 18, fontFamily: 'Nexa'),
            ),
          ),
        ),
      ),
    );
  }
}
