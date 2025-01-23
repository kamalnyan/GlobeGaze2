import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Screens/login_signup_screens/login_with_email_and_passsword.dart';
class Welcome2 extends StatefulWidget {
  final PageController controller;
  Welcome2({required this.controller});
  @override
  State<Welcome2> createState() => _Welcome2State();
}

class _Welcome2State extends State<Welcome2> {
  // Accept the PageController as a parameter
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     Colors.blue.shade100,
          //     Colors.white,
          //   ],
          // ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: SvgPicture.asset(
                  'assets/svg_images/Travelers-pana.svg',  // Replace with your second image asset
                  height: 300,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Discover Your Next Adventure',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white:Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      'Discover new places and share your experiences with others. Let’s start exploring!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color:  Color(0xffafb6c5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Handle Skip or back to Welcome1
                        widget.controller.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'Back',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: Material(
                        elevation: 10,
                        shadowColor: Color(0xff43dd8c),
                        borderRadius: BorderRadius.circular(40),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff43dd8c),
                          ),
                          child: Text('Get Started',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                          onPressed: () {
                           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Login()));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
