import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:seegle/resources/ondoard_data.dart';
import 'package:seegle/screens/auth/auth_wrapper.dart';
import 'package:seegle/screens/home_wrapper.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../styles.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../size_configs.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int currentPage = 0;

  final PageController _pageController = PageController(initialPage: 0);

  AnimatedContainer dotIndicator(index) {
    return AnimatedContainer(
      margin: const EdgeInsets.only(right: 5),
      duration: const Duration(milliseconds: 400),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: currentPage == index ? seegleYellow : seegleGray,
        shape: BoxShape.circle,
      ),
    );
  }

  Future setSeenonboard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    seenOnboard = await prefs.setBool('seenOnboard', true);
    // this will set seenOnboard to true when running onboard page for first time.
  }

  @override
  void initState() {
    super.initState();
    setSeenonboard();
  }

  @override
  Widget build(BuildContext context) {
    // initialize size config
    SizeConfig().init(context);
    double sizeV = SizeConfig.blockSizeV!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemCount: onboardingContents.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    SizedBox(
                      height: sizeV * 5,
                    ),
                    Text(
                      onboardingContents[index].title,
                      style: kTitle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: sizeV * 5,
                    ),
                    SizedBox(
                      height: sizeV * 50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Image.asset(
                          onboardingContents[index].image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: sizeV * 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(onboardingContents[index].subtitle,
                          style: kBodyText1, textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  currentPage == onboardingContents.length - 1
                      ? FloatingActionButton.extended(
                          label: const Text('Get Started! 🎉'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuthWrapper(),
                              ),
                            );
                            // MaterialPageRoute(
                            //   builder: (context) => HomeWrapper(),
                            // ));
                          },
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeWrapper(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              splashColor: Colors.black12,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Skip',
                                  style: kBodyText1,
                                ),
                              ),
                            ),
                            Row(
                              children: List.generate(
                                onboardingContents.length,
                                (index) => dotIndicator(index),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              splashColor: Colors.black12,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  'Next',
                                  style: kBodyText1,
                                ),
                              ),
                            )
                          ],
                        ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
