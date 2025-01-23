import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:globegaze/welcomescreen/welcome2.dart';
class Welcome1 extends StatelessWidget {
  final PageController controller;
  Welcome1({required this.controller});
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
                  'assets/svg_images/traveler-bro.svg', // Replace with your image asset
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
                    'Find Your Destination',
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
                      'All tourist destinations are in your hands. Just click and find the convenience now in phone.',
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
                        // Handle Skip
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xff43dd8c),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          controller.nextPage(duration: Duration(microseconds: 300), curve: Curves.easeInOut);
                        },
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
