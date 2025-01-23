import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:globegaze/components/textfield.dart';
import '../Screens/login_signup_screens/new_password.dart';
import '../Screens/login_signup_screens/Create_An_Account.dart';
import '../themes/colors.dart';
import '../themes/dark_light_switch.dart';
import 'Elevated_button.dart';
Widget topSection({required bool isDarkMode, required double screenHeight}) {
  return Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: EdgeInsets.only(
        top: screenHeight * 0.2,
        bottom: screenHeight * 0.2,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/png_jpeg_images/login_light.jpg'),
          fit: BoxFit.cover,
          colorFilter: isDarkMode
              ? ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken)
              : null,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Welcome to',
            style: TextStyle(color: Colors.white, fontSize: 21),
          ),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(text: 'G', style: TextStyle(color: PrimaryColor)),
                TextSpan(text: 'LOBE'),
                TextSpan(text: ' '),
                TextSpan(text: 'G', style: TextStyle(color: PrimaryColor)),
                TextSpan(text: 'AZE'),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
Widget bottomSection({required bool isDarkMode, required double screenHeight, required BuildContext context,
  required TextEditingController email,
  required TextEditingController password,
}) {
  return Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    top: screenHeight * 0.34,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkLight(isDarkMode),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Login Title
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: PrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Email or Phone TextField
            customTextField(isDarkMode: isDarkMode, name: 'Email Or Phone',icon: Icons.email,obs: false,keyboradType: TextInputType.text,controllerr: email),
            const SizedBox(height: 16),
            // Password TextField
            customTextField(isDarkMode: isDarkMode, name: 'Password',icon: CupertinoIcons.lock,obs:true,keyboradType: TextInputType.text,controllerr: password),
            const SizedBox(height: 16),
            // Forgot Password and Create Account links
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const NewPassword()));
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: LightDark(isDarkMode),
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const CreateAnAccount()));
                  },
                  child: Text(
                    'Create an account',
                    style: TextStyle(
                      color:  LightDark(isDarkMode),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Get Started Button
            SizedBox(
              width: 350,
              height: 50,
              child: Button(
                onPress: () {},
                text: 'Login',
                bgColor: PrimaryColor,
                fontSize: 17.0,
                fgColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // OR divider
            Text(
              'OR',
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode ? PrimaryColor : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Social login options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/svg_images/google-color-icon.svg',
                        height: 40,
                        width: 40,
                      ),
                    ),
                    Text(
                      'Google',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.apple),
                      iconSize: 50,
                    ),
                    Text(
                      'Apple',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/svg_images/facebook-round-color-icon.svg',
                        height: 40,
                        width: 40,
                      ),
                    ),
                    Text(
                      'Facebook',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}