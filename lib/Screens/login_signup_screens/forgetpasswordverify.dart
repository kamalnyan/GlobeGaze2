import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/Screens/login_signup_screens/login_with_email_and_passsword.dart';
import 'package:globegaze/components/textfield.dart'; // Import your custom text field
import 'package:globegaze/components/Elevated_button.dart'; // Import your custom button
import 'package:globegaze/themes/colors.dart';
import 'package:globegaze/themes/dark_light_switch.dart'; // Assuming PrimaryColor is here
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; // Add a loading state variable

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  Future<bool> isEmailRegistered(String email) async {
    try {
      // Assuming you have a 'users' collection in Firestore where email is stored
      CollectionReference users = FirebaseFirestore.instance.collection('Users');
      // Query the users collection to check if any document contains this email
      QuerySnapshot querySnapshot = await users.where('Email', isEqualTo: email).get();
      // If there's at least one document with this email, return true
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }
  Future<void> _sendResetPasswordEmail() async {
    final email = _emailController.text.trim();
    final isRegisterd = isEmailRegistered(email);
    if (email.isNotEmpty) {
      setState(() {
        _isLoading = true; // Start loading
      });
      if(await isRegisterd){
      try {
        // Send password reset email using Firebase Auth
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset email has been sent."),
            backgroundColor: PrimaryColor,
          ),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'No user found with this email.';
        } else if (e.code == 'invalid-email') {
          message = 'Invalid email address.';
        } else {
          message = 'Something went wrong. Please try again later.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Stop loading after the operation completes
        });
      }
    } else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email is not registerd'),
              backgroundColor: Colors.red,
            ),);
        setState(() {
          _isLoading = false; // Stop loading after the operation completes
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: PrimaryColor,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Reset',
                      style: TextStyle(
                        color: LightDark(isDarkMode),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Password',
                            style: TextStyle(
                              fontSize: 39,
                              fontWeight: FontWeight.bold,
                              color: LightDark(isDarkMode), // Your Primary color
                            ),
                          ),
                          const TextSpan(
                            text: '?',
                            style: TextStyle(
                              fontSize: 39,
                              fontWeight: FontWeight.bold,
                              color: PrimaryColor, // Your Primary color
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter the email address associated with your account.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    customTextField(
                      isDarkMode: isDarkMode, // Assuming you have a theme flag
                      name: 'Email',
                      icon: Icons.email,
                      obs: false,
                      keyboradType: TextInputType.emailAddress,
                      controllerr: _emailController,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Button(
                        onPress: _isLoading ? null : _sendResetPasswordEmail, // Disable button while loading
                        text: 'RESET PASSWORD',
                        bgColor: PrimaryColor, // Your Primary color
                        fontSize: 17.0,
                        fgColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 40,),
                    // Center(
                    //   child: OutlinedButton.icon(
                    //     onPressed: () {
                    //       Navigator.pop(context);
                    //     },
                    //     label: Text(
                    //       'Login',
                    //       style: TextStyle(color: PrimaryColor, fontSize: 21),
                    //     ),
                    //     icon: Icon(CupertinoIcons.arrow_left),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          // Show loading overlay when _isLoading is true
          if (_isLoading)
            const Opacity(
              opacity: 0.7,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading)
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                size: 100,
                color: PrimaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
