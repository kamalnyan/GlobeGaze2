import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../apis/APIs.dart';
import '../../components/custombutton.dart';
import '../../components/textfield.dart';
import '../../themes/colors.dart';


class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});
  @override
  State<DeleteAccount> createState() => _NewPasswordState();
}

class _NewPasswordState extends State<DeleteAccount> {
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool isobs = true;
  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    setState(() {
      isLoading = true;
    });
    String password = _passwordController.text.trim();
    if (password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your password.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
      return;
    }
    await Apis.deleteUserAccount(context, password);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delete Account',
          style: TextStyle(color: textColor(context)),
        ),
        backgroundColor: isDarkMode ? darkBackground : Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor(context)),
      ),
      body: Center(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 17, right: 17),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const Icon(CupertinoIcons.trash_circle_fill,
                          size: 200, color: Colors.red),
                      SizedBox(height: screenHeight / 20),
                      Text(
                        '• Once the account is deleted, it cannot be recovered',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.withValues(alpha: 0.5),
                        ),
                      ),
                      Text(
                        '• All data, including expenses, analytics, and preferences, will be permanently lost.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: screenHeight / 21),
                      customTextField1(
                          context: context,
                          name: 'Enter Password',
                          obs: isobs,
                          keyboradType: TextInputType.visiblePassword,
                          icon: CupertinoIcons.lock,
                          controllerr: _passwordController,
                          isobs: isobs,
                          onPressed: () {
                            setState(() {
                              isobs = !isobs;
                            });
                          }),
                      SizedBox(height: screenHeight / 25),
                      buildButton(
                          onTap: _deleteAccount,
                          text: 'Delete Permanently',
                          bgColor: Colors.red,
                          textColor: Colors.white,
                          context: context),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              const Opacity(
                  opacity: 0.7,
                  child: ModalBarrier(dismissible: false, color: Colors.black)),
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
