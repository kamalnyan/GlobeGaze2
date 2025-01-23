import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globegaze/components/Elevated_button.dart';
import 'package:globegaze/components/textfield.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:globegaze/themes/dark_light_switch.dart';

import 'login_with_email_and_passsword.dart';
import 'otp_screen.dart';

class forgetPassword extends StatefulWidget {
  const forgetPassword({super.key});

  @override
  State<forgetPassword> createState() => _forgetPasswordState();
}

class _forgetPasswordState extends State<forgetPassword> {
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    // Get the screen width dynamically
    double screenHieght = MediaQuery.of(context).size.height;

    // Set a dynamic margin based on the screen width
    double dynamicMargin = screenHieght * 0.18; 

    return  Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        title: const Text('Forget Password'),
        centerTitle: true,
      ),
      body:   SingleChildScrollView(
        child: Container(
          margin:  EdgeInsets.only(top: dynamicMargin),
          width: double.infinity,
          child:  Column(
            children: [
              Text('Enter Email Address', style: TextStyle(
                  fontSize: 22,
                fontWeight: FontWeight.bold,

                color: LightDark(isDarkMode),
              ),
              ),
              const SizedBox(
                height: 18,
              ),
             Padding(
               padding: EdgeInsets.all( 40.02),
               child: customTextField(isDarkMode: isDarkMode, name: 'Email', obs: false, keyboradType: TextInputType.name, icon: Icons.email_outlined)
             ),
              const SizedBox(
                height: 18,
              ),
              TextButton(onPressed: () {
                Navigator.pop(context, MaterialPageRoute(builder: (context)=>const Login()));
              },
                  child: const Text('Back to Sign in',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17
                  ),
                  )
              ),
              const SizedBox(
                height: 18,
              ),
              SizedBox(
                width: 220,
                height: 50,
                child: Button(
                  onPress: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const otp_screen()));
                  },
                  text: 'Send',
                  bgColor: PrimaryColor,
                  fontSize: 17.0,
                  fgColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
