import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/home_screens/main_home.dart';
import 'Screens/login_signup_screens/login_with_email_and_passsword.dart';
import 'apis/APIs.dart';
import 'main.dart';
import 'welcomescreen/welcomemain.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SharedPreferences? shareP;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    sharePreferences();
  }

  Future<void> sharePreferences() async {
    shareP = await SharedPreferences.getInstance();
    bool showWelcomeScreen = shareP?.getBool('welcomedata') ?? true;
    User? currentUser = _auth.currentUser;
    Timer(const Duration(seconds: 2), () {
      if (showWelcomeScreen) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      } else if (currentUser != null) {
        Apis.fetchUserInfo();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainHome()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    mq=MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 25,
                  color: isDarkMode ? Colors.white : Color(0xff48566a), // Text color
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text: 'G',
                    style: TextStyle(color: Color(0xff43dd8c)),
                  ),
                  TextSpan(text: 'LOBE'),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: 'G',
                    style: TextStyle(color: Color(0xff43dd8c)),
                  ),
                  TextSpan(text: 'AZE'),
                ],
              ),
            ),
            SizedBox(height: 40),
            Lottie.asset( 'assets/lottie_animation/splashCompass.json',
              // isDarkMode
              //     ? 'assets/lottie_animation/darkanimationspalsh.json'
              //     : 'assets/lottie_animation/lightanimationspalsh.json',
              repeat: true,
              animate: true,
              frameRate: FrameRate(120),
            ),
          ],
        ),
      ),
    );
  }
}
