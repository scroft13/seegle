import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seegle/styles.dart';
import 'package:seegle/widgets/custom_dialog.dart';
import 'add_flock_button.dart';

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
      color: Color(0xFFeeeeee),
      child: SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home_outlined),
              iconSize: 30,
              onPressed: () {
                setIndex(0);
              },
              color:
                  currentIndex == 0 ? AppColors.darkGrey : AppColors.mediumGrey,
            ),
            CupertinoButton(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  // color: Colors.blue,
                  borderRadius: BorderRadius.circular(
                      50), // 50% of the container's height
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_sharp,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'New Flock',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    // Dialog cannot be dismissed by tapping outside

                    return const MyCustomDialog();
                  },
                );
              },
            ),
            const AddFlockButton(),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                setIndex(1);
                currentIndex = 1;
              },
              color:
                  currentIndex == 1 ? AppColors.darkGrey : AppColors.mediumGrey,
            ),
          ],
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
