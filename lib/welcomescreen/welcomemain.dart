import 'package:flutter/material.dart';
import 'package:globegaze/welcomescreen/welcome1.dart';
import 'package:globegaze/welcomescreen/welcome2.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
class WelcomeScreen extends  StatefulWidget{
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
          children: [
            PageView(
              controller: _controller,
              children: [
                Welcome1(controller: _controller,),
                Welcome2(controller: _controller,),
              ],
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.45,
              child: SmoothPageIndicator(
                controller: _controller,
                count: 2,
                effect:  ExpandingDotsEffect(
                dotColor: Color(0xffafb6c5),
                activeDotColor: Color(0xff43dd8c),
                ),
              ),
            ),
          ],
        ),
    );
  }
}