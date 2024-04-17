// ignore_for_file: deprecated_member_use
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seegle/models/button_group_calls.dart';
import 'package:seegle/models/sliding_settings_control_rating.dart';
import 'package:seegle/models/user.dart';
import 'package:seegle/screens/auth/delete.dart';
import 'package:seegle/screens/home_wrapper.dart';
import 'package:seegle/screens/privacy.dart';
import 'package:seegle/screens/auth/update_username.dart';
import 'package:seegle/screens/terms.dart';
import 'package:url_launcher/url_launcher.dart';
import '../styles.dart';
import 'auth/auth_wrapper.dart';
import 'package:getwidget/getwidget.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // int _internetPoints = 0;

  Color darkGray(Set<MaterialState> states) {
    return const Color(0xFF333333);
  }

  Color yella(Set<MaterialState> states) {
    return const Color(0xFFFFCC00);
  }

  final User? user = FirebaseAuth.instance.currentUser;

  getUserInfo() async {
    if (FirebaseAuth.instance.currentUser != null) {
      var userCheck = await usersRef.doc(user!.uid).get();
      currentUser = CustomUser.fromDocument(userCheck);
      return currentUser;
    }
  }

  _updateUsername() {
    Get.to(() => UpdateUsername());
  }

  _signOut() {
    FirebaseAuth.instance.signOut();
    currentUser = null;
    Get.offAll(() => HomeWrapper());
  }

  Future<void> _contactSupport() async {
    const link =
        "mailto:support@seegle.app?subject=Seegle%20App%20$versionNumber";
    if (await canLaunch(link)) {
      await launch(link);
    } else {
      throw 'Could not launch $link';
    }
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String nameSubString = "";
    currentUser != null
        ? setState(() {
            nameSubString = currentUser!.username.substring(0, 3);
          })
        : null;
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                currentUser != null
                    ? Text('Welcome ${currentUser!.username}!',
                        style: Styles.postCallBodyText)
                    : const Text('Welcome'),
                currentUser != null
                    ? currentUser!.photoUrl != null
                        ? CircleAvatar(
                            backgroundImage:
                                NetworkImage(currentUser!.photoUrl.toString()),
                          )
                        : CircleAvatar(
                            child: Text(nameSubString),
                          )
                    : const CircleAvatar()
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Internet Points: ", style: Styles.postCallBodyText),
                  currentUser != null
                      ? Text(currentUser!.internetPoints.toString(),
                          style: Styles.postCallBodyText)
                      : const CircularProgressIndicator(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: const Color(0xFF333333),
                    child: GFAccordion(
                      contentBorderRadius: BorderRadius.circular(20.0),
                      contentBackgroundColor: const Color(0xFFFFFFFF),
                      expandedTitleBackgroundColor: const Color(0xFF333333),
                      collapsedTitleBackgroundColor: const Color(0xFF333333),
                      textStyle: const TextStyle(
                          color: Color(0xFFFFCC00),
                          fontFamily: 'NexaLight',
                          fontSize: 18),
                      title: 'Profile Settings',
                      collapsedIcon: const Icon(
                        Icons.expand_more_sharp,
                        color: Color(0xFFFFCC00),
                      ),
                      expandedIcon: const Icon(
                        Icons.expand_less_sharp,
                        color: Color(0xFFFFCC00),
                      ),
                      contentChild: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Current Username:',
                                    style: Styles.subTitle,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6.0),
                                    child: Text(
                                      currentUser?.username != null
                                          ? currentUser!.username
                                          : 'Loading',
                                      style: Styles.subTitle,
                                    ),
                                  ),
                                ],
                              ),
                              // RaisedButton(
                              //     child: const Text('Update'),
                              //     materialTapTargetSize:
                              //         MaterialTapTargetSize.shrinkWrap,
                              //     onPressed: _updateUsername),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Currently signed in with:',
                                    style: Styles.subTitle,
                                  ),
                                  currentUser != null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6.0),
                                          child: Text(
                                            currentUser!.email,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'NexaLight'),
                                          ),
                                        )
                                      : const Text(
                                          'Loading',
                                          style: Styles.subTitle,
                                        ),
                                ],
                              ),
                              // RaisedButton(
                              //   child: const Text('Sign Out'),
                              //   onPressed: _signOut,
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: const Color(0xFF333333),
                    child: GFAccordion(
                      contentBorderRadius: BorderRadius.circular(20.0),
                      collapsedTitleBackgroundColor: const Color(0xFF333333),
                      expandedTitleBackgroundColor: const Color(0xFF333333),
                      contentBackgroundColor: const Color(0xFFFFFFFF),
                      collapsedIcon: const Icon(
                        Icons.expand_more_sharp,
                        color: Color(0xFFFFCC00),
                      ),
                      expandedIcon: const Icon(
                        Icons.expand_less_sharp,
                        color: Color(0xFFFFCC00),
                      ),
                      textStyle: const TextStyle(
                          color: Color(0xFFFFCC00),
                          fontFamily: 'NexaLight',
                          fontSize: 18),
                      title: 'Rate Your Knowledge',
                      contentChild: currentUser != null
                          ? ListView(
                              shrinkWrap: true,
                              children: [
                                CustomSliderRating(
                                    category: 'cannabis',
                                    title: 'Cannabis Cultivation',
                                    uid: currentUser!.id,
                                    username: currentUser!.username),
                                CustomSliderRating(
                                    category: 'mushrooms',
                                    title: 'Mushroom Cultivation',
                                    uid: currentUser!.id,
                                    username: currentUser!.username),
                              ],
                            )
                          : const Text('Loading'),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: const Color(0xFF333333),
                    child: GFAccordion(
                      contentBorderRadius: BorderRadius.circular(20.0),
                      collapsedTitleBackgroundColor: const Color(0xFF333333),
                      expandedTitleBackgroundColor: const Color(0xFF333333),
                      contentBackgroundColor: const Color(0xFFFFFFFF),
                      collapsedIcon: const Icon(
                        Icons.expand_more_sharp,
                        color: Color(0xFFFFCC00),
                      ),
                      expandedIcon: const Icon(
                        Icons.expand_less_sharp,
                        color: Color(0xFFFFCC00),
                      ),
                      textStyle: const TextStyle(
                          color: Color(0xFFFFCC00),
                          fontFamily: 'NexaLight',
                          fontSize: 18),
                      title: 'Who do you want to help?',
                      contentChild: Column(
                        children: [
                          const Text(
                            "Choose the categories that you want to receive calls in below:",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          ButtonGroupCalls(
                              category: 'cannabis',
                              title: 'Cannabis Cultivation',
                              uid: currentUser?.id,
                              username: currentUser?.username),
                          ButtonGroupCalls(
                              category: 'mushrooms',
                              title: 'Mushroom Cultivation',
                              uid: currentUser?.id,
                              username: currentUser?.username),
                          currentUser != null
                              ? currentUser!.isAdmin
                                  ? ButtonGroupCalls(
                                      category: 'testing',
                                      title: 'Testing',
                                      uid: currentUser?.id,
                                      username: currentUser?.username)
                                  : const Text("")
                              : const Text(""),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    color: const Color(0xFF333333),
                    child: GFAccordion(
                      contentBorderRadius: BorderRadius.circular(20.0),
                      collapsedTitleBackgroundColor: const Color(0xFF333333),
                      expandedTitleBackgroundColor: const Color(0xFF333333),
                      contentBackgroundColor: const Color(0xFFFFFFFF),
                      collapsedIcon: const Icon(
                        Icons.expand_more_sharp,
                        color: Color(0xFFFFCC00),
                      ),
                      expandedIcon: const Icon(
                        Icons.expand_less_sharp,
                        color: Color(0xFFFFCC00),
                      ),
                      textStyle: const TextStyle(
                          color: Color(0xFFFFCC00),
                          fontFamily: 'NexaLight',
                          fontSize: 18),
                      title: 'Legal Stuff',
                      contentChild: ListView(
                        shrinkWrap: true,
                        children: const [
                          Terms(),
                          Privacy(),
                          DeleteAccount(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 150,
                  ),
                  Column(
                    children: [
                      FloatingActionButton.extended(
                        onPressed: _contactSupport,
                        label: const Text("Contact Us"),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text("Version $versionNumber"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
