import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/Screens/home_screens/main_home.dart';
import 'package:globegaze/themes/colors.dart';
import '../../apis/APIs.dart';
import '../../themes/dark_light_switch.dart';
import 'login_with_email_and_passsword.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  VerifyEmailScreen(this.email);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isEmailVerified = false;
  bool isResendLinkSent = false;
  Timer? emailVerificationTimer;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    Apis.fetchUserInfo();
    // Check if the email is already verified when the screen loads
    if (user != null) {
      isEmailVerified = user!.emailVerified;
      if (isEmailVerified) {
        _navigateToHome();
      } else {
        Apis.sendVerificationEmail(user!, context);
        // Start checking email verification status every 3 seconds
        emailVerificationTimer = Timer.periodic(Duration(seconds: 3), (timer) {
          checkEmailVerified();
        });
      }
    }
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    emailVerificationTimer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await user?.reload(); // Reload user data
    user = _auth.currentUser; // Update the user instance
    setState(() {
      isEmailVerified = user?.emailVerified ?? false;
    });
    if (isEmailVerified) {
      // Cancel the timer once email is verified
      emailVerificationTimer?.cancel();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Email Verified Successfully!"),
      //     backgroundColor: PrimaryColor,
      //   ),
      // );
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    // Navigate to the main home screen and clear the back stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainHome()),
          (route) => false, // Remove all previous routes
    );
  }

  Future<void> resendVerification() async {
    try {
      await user?.sendEmailVerification();
      setState(() {
        isResendLinkSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verification email resent to ${widget.email}"),
          backgroundColor: PrimaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error resending verification email."),
          backgroundColor: PrimaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkLight(isDarkMode),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail,
                  size: 100.0,
                  color: PrimaryColor,
                ),
                SizedBox(height: 24.0),
                Text(
                  'Verify your email address',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: LightDark(isDarkMode),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                Text(
                  'We have sent a verification link to your email. '
                      'Please check your email and click on the link to verify your email address.',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: LightDark(isDarkMode),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                Text(
                  'If not auto redirected after verification, click on the Continue button.',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: LightDark(isDarkMode),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: isEmailVerified
                      ? _navigateToHome // If verified, navigate to Home
                      : checkEmailVerified, // Manually check if not auto-redirected
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: PrimaryColor),
                    ),
                    backgroundColor: darkLight(isDarkMode),
                    foregroundColor: PrimaryColor,
                    elevation: 0,
                    padding:
                    EdgeInsets.symmetric(horizontal: 40.0, vertical: 14.0),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextButton(
                  onPressed: isResendLinkSent
                      ? null // Disable button after sending link
                      : resendVerification,
                  child: Text(
                    'Resend E-Mail Link',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => Login()));
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.blue),
                  label: Text(
                    'Back to login',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
