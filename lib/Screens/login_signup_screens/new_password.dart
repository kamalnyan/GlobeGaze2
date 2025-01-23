import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/components/textfield.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:globegaze/themes/dark_light_switch.dart';
import '../../components/Elevated_button.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});

  @override
  State<NewPassword> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<NewPassword> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    // Validate passwords
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      // Get current user
      User? user = _auth.currentUser;
      if (user != null) {
        // Update the password
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully.'), backgroundColor: Colors.green),
        );
        // You can navigate the user to the login screen or another appropriate screen
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    // Get the screen height dynamically
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Password'),
        backgroundColor: PrimaryColor,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  'Enter New Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: LightDark(isDarkMode),
                  ),
                ),
                SizedBox(height: screenHeight / 21),
                Padding(
                  padding: EdgeInsets.only(
                      left:  17, right:  17),
                  child: customTextField(
                    isDarkMode: isDarkMode,
                    name: 'New Password',
                    obs: true, // Password should be obscured
                    keyboradType: TextInputType.visiblePassword,
                    icon: CupertinoIcons.lock,
                    controllerr: _newPasswordController,
                  ),
                ),
                SizedBox(height: screenHeight / 25),
                Padding(
                  padding: EdgeInsets.only(
                      left:  17, right: 17),
                  child: customTextField(
                    isDarkMode: isDarkMode,
                    name: 'Confirm New Password',
                    obs: true, // Password should be obscured
                    keyboradType: TextInputType.visiblePassword,
                    icon: CupertinoIcons.lock,
                    controllerr: _confirmPasswordController,
                  ),
                ),
                SizedBox(height: screenHeight / 25),
                SizedBox(
                  width: 220,
                  height: 50,
                  child: Button(
                    onPress: _changePassword, // Call the change password function
                    text: 'Done',
                    bgColor: PrimaryColor,
                    fontSize: 17.0,
                    fgColor: Colors.white,
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
