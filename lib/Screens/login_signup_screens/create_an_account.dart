import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apis/APIs.dart';
import '../../components/Elevated_button.dart';
import '../../components/EmailValidator.dart';
import '../../components/login_signup_components.dart';
import '../../components/textfield.dart';
import '../../themes/colors.dart';
import '../../themes/dark_light_switch.dart';
class CreateAnAccount extends StatefulWidget {
  const CreateAnAccount({super.key});
  @override
  State<CreateAnAccount> createState() => CreateAccountState();
}
class CreateAccountState extends State<CreateAnAccount> {
  final TextEditingController _fullname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmpassword = TextEditingController();
  late String _completePhone;
  late SharedPreferences shareP;
  bool _isLoading = false; // Track if the signup process is ongoing
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true; // Show loading animation
    });
    try {
      final fullName = _fullname.text.toString();
      final emaill = _email.text.toString();
      final passwordd = _password.text.toString();
      final confirmPassword = _confirmpassword.text.toString();
      if (fullName.isEmpty || fullName.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'Full Name must be at least 3 characters long'),backgroundColor: PrimaryColor,),
        );
      } else if (_completePhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid Phone Number'),backgroundColor: PrimaryColor,),
        );
      } else if (!isValidEmail(emaill)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email'),backgroundColor: PrimaryColor,),
        );
      } else if (passwordd.isEmpty || passwordd.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'Password must be at least 6 characters long'),backgroundColor: PrimaryColor,),
        );
      } else if (passwordd != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match'),backgroundColor: PrimaryColor,),
        );
      }else{
       await Apis.signUpWithEmailPassword(
            fullName: fullName,
            about: 'hey ! lets travel',
            image: 'assets/png_jpeg_images/user.jpg',
            isOnline: false,
            lastActive: Timestamp.now().toString(),
            email: emaill,
            phone: _completePhone,
            password: passwordd,
            pushToken: '',
            isUerAdded: true,
            context: context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup Failed!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    sharePreferences();
  }
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: isDarkMode ? const Color(0xFF121212) : Colors.white,
        child: Stack(
          children: [
            // Background image section at the top
            topSection(isDarkMode: isDarkMode, screenHeight: screenHeight),
            // Login form section at the bottom
            Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          top: screenHeight * 0.30,
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
                      'Create your account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: PrimaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email or Phone TextField
                  customTextField(isDarkMode: isDarkMode, name: 'Full Name',icon: Icons.account_circle,obs: false,keyboradType: TextInputType.name,controllerr: _fullname),
                  const SizedBox(height: 16),
                  // Phone TextField
                  IntlPhoneField (
                    keyboardType: TextInputType.phone,
                    cursorColor: PrimaryColor,
                    style: TextStyle(color: LightDark(isDarkMode)),
                    // focusNode: focusNode,
                    decoration: InputDecoration(
                      label: Text('Phone Number',style: TextStyle(color:LightDark(isDarkMode)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                        borderSide: const BorderSide(color: PrimaryColor),
                      ),
                    ),
                    dropdownIcon: const Icon(Icons.arrow_drop_down_outlined,color: PrimaryColor,),
                    languageCode: "en",
                    initialCountryCode: 'IN',
                    dropdownTextStyle: const TextStyle(color: PrimaryColor),
                    onChanged: (phone) {
                      _completePhone=phone.completeNumber;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email TextField
                  customTextField(isDarkMode: isDarkMode, name: 'Email',icon: Icons.email,obs: false,keyboradType: TextInputType.emailAddress,controllerr: _email),
                  const SizedBox(height: 16),
                  // Password TextField
                  customTextField(isDarkMode: isDarkMode, name: 'Password',icon: CupertinoIcons.lock,obs: true,keyboradType: TextInputType.text,controllerr: _password),
                  const SizedBox(height: 16),
                  // Password TextField
                  customTextField(isDarkMode: isDarkMode, name: 'Confirm Password',icon: CupertinoIcons.lock,obs: true,keyboradType: TextInputType.text,controllerr: _confirmpassword),
                  const SizedBox(height: 32),
                  // Forgot Password and Create Account links
                  SizedBox(
                    width: 300,
                    height: 50,
                    child: Button(
                        text: 'Signup',
                        bgColor: PrimaryColor,
                        fontSize: 17.0,
                        fgColor: Colors.white,
                        onPress:  _isLoading ? null : _signUp,),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),),
            if (_isLoading)
              const Opacity(
                opacity: 0.7,
                child: ModalBarrier(dismissible: false, color: Colors.black),),
            if (_isLoading)
              Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  size: 67, color: PrimaryColor,
                ),),
          ],
        ),
      ),
    );
  }
  // Shared Preference for welcome_Screen
  Future<void> sharePreferences() async {
    shareP = await SharedPreferences.getInstance();
    shareP.setBool('welcomedata', false);
  }
}