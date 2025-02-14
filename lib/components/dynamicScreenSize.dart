import 'package:flutter/cupertino.dart';

class ScreenSize {
  final double width;
  final double height;
  final double shortestSide;
  ScreenSize(this.width, this.height,this.shortestSide);
}

ScreenSize getScreenSize(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final shortestSide = MediaQuery.of(context).size.shortestSide;
  return ScreenSize(screenWidth, screenHeight,shortestSide);
}
double getResponsiveTextScaleFactor(BuildContext context) {
  final screenSize = getScreenSize(context);
  final screenWidth = screenSize.width;
  final screenHeight = screenSize.height;
  final aspectRatio = screenHeight/ screenWidth;

  if (screenWidth < 360 || screenHeight < 640) {
    return 0.7; // Extra small screens (very small phones)
  } else if ((screenWidth < 480 || screenHeight < 800) || aspectRatio > 1.8) {
    return 0.8; // Small phones or very tall devices
  } else if ((screenWidth < 768 && screenHeight < 1024) || (aspectRatio > 1.5 && aspectRatio <= 1.8)) {
    return 0.9; // Medium phones or slightly tall devices
  } else if ((screenWidth >= 768 && screenWidth < 1024) || (screenHeight >= 1024 && screenHeight < 1280) || (aspectRatio > 1.3 && aspectRatio <= 1.5)) {
    return 1.1; // Small tablets
  } else if ((screenWidth >= 1024 && screenWidth < 1280) || (screenHeight >= 1280 && screenHeight < 1440) || (aspectRatio > 1.2 && aspectRatio <= 1.3)) {
    return 1.2; // Standard tablets
  } else if ((screenWidth >= 1280 && screenWidth < 1440) || (screenHeight >= 1440 && screenHeight < 1600) || (aspectRatio >= 1.0 && aspectRatio <= 1.2)) {
    return 1.3; // Large tablets or small desktops
  } else if (screenWidth >= 1440 && screenWidth < 1920 || screenHeight >= 1600 && screenHeight < 2160) {
    return 1.4; // Desktops
  } else if (screenWidth >= 1920 && screenWidth < 2560 || screenHeight >= 2160 && screenHeight < 2880) {
    return 1.6; // Large desktops
  } else if ((screenWidth == 800 && screenHeight == 1280) ||
      (screenWidth == 1024 && screenHeight == 1350) ||
      (screenWidth == 1280 && screenHeight == 1800)) {
    return 2.0;
  }else {
    return 1.8; // Ultra-wide screens
  }
}

