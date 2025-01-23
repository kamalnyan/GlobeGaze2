import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:globegaze/Screens/home_screens/main_home.dart';
import 'package:globegaze/Screens/login_signup_screens/verifyemail.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apis/APIs.dart';
import '../../components/Elevated_button.dart';
import '../../components/customNavigation.dart';
import '../../components/login_signup_components.dart';
import '../../components/textfield.dart';
import '../../themes/colors.dart';
import '../../themes/dark_light_switch.dart';
import 'forgetpasswordverify.dart';
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}
class LoginState extends State<Login> {
  late SharedPreferences shareP;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  bool _isLoading = false;
  Future<void> _signInWithEmailPassword() async {
    final _Email=_email.text.trim();
    final _Password=_password.text.trim();
    if(_Email.isEmpty || _Password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid email or password'),
          backgroundColor: Colors.red,
        ),
      );
    }else {
      setState(() {
        _isLoading = true;
      });
      try {
        final UserCredential userCredential = await _auth
            .signInWithEmailAndPassword(
          email: _Email,
          password: _Password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Successful'),
            backgroundColor: PrimaryColor,
          ),
        );
        if(userCredential.user!.emailVerified){
           Apis.fetchUserInfo();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainHome()));
          await loginScuess();
        }else{
          Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyEmailScreen(_Email)));
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An unexpected error occurred. Please try again later.';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email.';
        } else if (e.code == 'invalid-credential') {
          errorMessage = 'Incorrect email or password. Please try again.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Incorrect email.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        color: isDarkMode ? const Color(0xFF121212) : Colors.white, // Professional dark and light background
        child: Stack(
          children: [
            // Background image section at the top
            topSection(isDarkMode: isDarkMode, screenHeight: screenHeight),
            // Login form section at the bottom
            Positioned(
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
                  customTextField(isDarkMode: isDarkMode, name: 'Email',icon: Icons.email,obs: false,keyboradType: TextInputType.emailAddress,controllerr: _email),
                  const SizedBox(height: 16),
                  // Password TextField
                  customTextField(isDarkMode: isDarkMode, name: 'Password',icon: CupertinoIcons.lock,obs:true,keyboradType: TextInputType.text,controllerr: _password),
                  const SizedBox(height: 16),
                  // Forgot Password and Create Account links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> ForgotPassword()));
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
                          Navigator.push(context, createRoute());
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
                      onPress:  _isLoading ? null : _signInWithEmailPassword,
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
        ),
            if (_isLoading)
              const Opacity(
                opacity: 0.7,
                child: ModalBarrier(dismissible: false, color: Colors.black),),
            if (_isLoading)
              Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  size: 100, color: PrimaryColor,
                ),),
          ],
        ),
      ),
    );
  }
  // Shared Preference for welcome_Screen and login
  Future<void> loginScuess() async{
    shareP = await SharedPreferences.getInstance();
    shareP.setBool('welcomedata', false);
    shareP.setBool('login', true);
  }
}
