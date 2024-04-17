import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'advisory.dart';
import 'home.dart';

class AdvisoryCheck extends StatefulWidget {
  const AdvisoryCheck({Key? key}) : super(key: key);

  @override
  _AdvisoryCheckState createState() => _AdvisoryCheckState();
}

class _AdvisoryCheckState extends State<AdvisoryCheck> {
  bool? seenAdvisory = false;
  bool advisoryCheck = false;
 
  _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    seenAdvisory = prefs.getBool('seenAdvisory');
    if(seenAdvisory == null){
      prefs.setBool('seenAdvisory', false);
    }  else if (seenAdvisory == true) {
      setState(() {
        advisoryCheck = true;
      });
    } 
  }
  
    
  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return advisoryCheck ? const Home() : const Advisory();
  }
}
