import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

Widget loadinganimation(){
  return Center(
      child: LoadingAnimationWidget.discreteCircle(
      color: PrimaryColor,
      size: 200,)
  );
}
Widget loadinganimation2(){
  return LoadingAnimationWidget.inkDrop(
    color: PrimaryColor,
    size: 50,);
}
Widget uploadingAnimation() {
  return Center(
    child: SizedBox(
      width: 200,
      height: 200,
      child: Lottie.asset(
        'assets/lottie_animation/uploading2.json',
        repeat: true,
        animate: true,
        frameRate: FrameRate(120), // Set the frame rate here
      ),
    ),
  );
}