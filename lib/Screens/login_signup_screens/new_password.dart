import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../apis/APIs.dart';
import '../../components/custombutton.dart';
import '../../components/dynamicScreenSize.dart';
import '../../components/textfield.dart';
import '../../themes/colors.dart';
import '../../themes/dark_light_switch.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  bool isLoading=false;
  bool isobs= true;
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() {
      isLoading=true;
    });
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String oldPassword = _oldPasswordController.text.trim();
    if (newPassword.isEmpty || confirmPassword.isEmpty || oldPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.'), backgroundColor: Colors.red),
      );
      setState(() {
        isLoading=false;
      });
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.'), backgroundColor: Colors.red),
      );
      setState(() {
        isLoading=false;
      });
      return;
    }
    try {
      await Apis.changePassword(context, newPassword,oldPassword);
      _oldPasswordController.text="";
      _newPasswordController.text="";
      _confirmPasswordController.text="";
      setState(() {
        isLoading=false;
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading=false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    final screenSize = getScreenSize(context);
    final scallText = screenSize.shortestSide/600;
    final screenW = screenSize.width;
    final screenh = screenSize.height;
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: textColor(context)
        ),
        backgroundColor: isDarkMode? darkBackground : Colors.white,
        title: Text('Change Password', style: TextStyle(color: textColor(context),fontSize: 36*scallText)),
      ),
      body: Center(
        child: Stack(
          children:[
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left:  17, right:  17),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(height: 10.0),
                      const Icon(CupertinoIcons.lock_circle_fill,size: 200,color: PrimaryColor),
                      SizedBox(height: screenh / 21),
                      Text(
                        'Enter New Password',
                        style: TextStyle(
                          fontSize: 28*scallText,
                          fontWeight: FontWeight.bold,
                          color: LightDark(isDarkMode),
                        ),
                      ),
                      SizedBox(height: screenh / 21),
                      customTextField1(
                          context: context,
                          name: 'Old Password',
                          obs: isobs,
                          keyboradType: TextInputType.visiblePassword,
                          icon: CupertinoIcons.lock,
                          controllerr: _oldPasswordController,
                          isobs: isobs,
                          onPressed:(){
                            setState(() {
                              isobs=!isobs;
                            });
                          }
                      ),
                      SizedBox(height: screenh / 25),
                      customTextField1(
                          context: context,
                          name: 'New Password',
                          obs: isobs, // Password should be obscured
                          keyboradType: TextInputType.visiblePassword,
                          icon: CupertinoIcons.lock,
                          controllerr: _newPasswordController,
                          isobs: isobs,
                          onPressed:(){
                            setState(() {
                              isobs=!isobs;
                            });
                          }
                      ),
                      SizedBox(height: screenh / 25),
                      customTextField1(
                          context: context,
                          name: 'Confirm New Password',
                          obs: isobs,
                          keyboradType: TextInputType.visiblePassword,
                          icon: CupertinoIcons.lock,
                          controllerr: _confirmPasswordController,
                          isobs: isobs,
                          onPressed:(){
                            setState(() {
                              isobs=!isobs;
                            });
                          }
                      ),
                      SizedBox(height: screenh / 25),
                      buildButton(
                          onTap: _changePassword,
                          text: 'Done',
                          bgColor: isDarkMode?primaryDarkBlue:gradientEndColor,
                          textColor: Colors.white,
                          context: context
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if( isLoading)
              const Opacity(opacity: 0.7,
                  child: ModalBarrier(dismissible: false, color: Colors.black)
              ),
            if (isLoading)
              Center(
                child: Lottie.asset(
                  'assets/Lottie/splashLoading.json',
                  width: 200,
                  height: 200,
                  repeat: true, // Loop the animation
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
