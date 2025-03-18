import 'package:seegle/seegle_icons.dart';
import 'package:flutter/material.dart';
import 'package:seegle/styles.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int) onTap;

  const CustomBottomNavigationBar({super.key, required this.onTap});
  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBar();
}

class _CustomBottomNavigationBar extends State<CustomBottomNavigationBar> {
  int currentIndex = 0;

  void setIndex(number) {
    setState(() {
      currentIndex = number;
      widget.onTap(number);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFFFFFFF),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Seegle.hero),
                iconSize: currentIndex == 0 ? 40 : 30,
                onPressed: () {
                  setIndex(0);
                },
                color: currentIndex == 0
                    ? AppColors.darkGrey
                    : AppColors.mediumGrey,
              ),
              IconButton(
                icon: const Icon(Seegle.squawkIcon),
                iconSize: currentIndex == 1 ? 40 : 30,
                onPressed: () {
                  setIndex(1);
                },
                color: currentIndex == 1
                    ? AppColors.darkGrey
                    : AppColors.mediumGrey,
              ),
              IconButton(
                iconSize: currentIndex == 2 ? 40 : 30,
                icon: const Icon(Seegle.winston),
                onPressed: () {
                  setIndex(2);
                },
                color: currentIndex == 2
                    ? AppColors.darkGrey
                    : AppColors.mediumGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final Widget icon;
  final String? label;

  BottomNavItem({required this.icon, this.label});
}
