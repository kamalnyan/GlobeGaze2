import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../components/isDarkMode.dart';
const Color ChatBack = Color(0xffF9F9F9);
const Color DChatBack = Color(0xff1E1E1E);
const Color PrimaryColor = Color(0xff43dd8c);
const Color ReciverBackg = Color(0xffF1F1F1);
const Color ReciverTxt = Color(0xff333333);
const Color SenderBAckg = Color(0xff007AFF);
const Color SenderTxt = Color(0xffFFFFFF);
const Color DReciverBackg = Color(0xff2C2C2E);
const Color DReciverTxt = Color(0xffD1D1D1);
const Color DSenderBAckg = Color(0xff007AFF);
const Color DSenderTxt = Color(0xffFFFFFF);
const Color Timetxt = Color(0xff999999);
const Color DTimetxt = Color(0xff555555);
const Color Iconsshado = Color(0xff007AFF);
const Color Textfieldlight = Color(0xff222224);
const Color Textfielddark = Color(0xFFF5F5F4);
const Color Containerdark = Color(0xFF1E1E2A);
const Color primaryDarkBlue = Color(0xFF2C3E50); // Dark Blue
const Color primaryBrightCyan = Color(0xFF1ABC9C); // Bright Cyan
const Color accentGoldenYellow = Color(0xFFF1C40F); // Golden Yellow
const Color accentCoralRed = Color(0xFFE74C3C); // Coral Red
const Color neutralLightGrey = Color(0xFFECF0F1); // Light Grey
const Color neutralMediumGrey = Color(0xFF95A5A6); // Medium Grey
const Color neutralCharcoalGrey = Color(0xFF7F8C8D); // Charcoal Grey
const Color darkBackground = Color(0xFF021526); // Dark Theme Background
const Color darkCardColor = Color(0xFF2C3E50); // Dark Theme Card
const Color darkDivider = Color(0xFF16A085); // Dark Cyan Divider
const Color gradientStartColor = Color(0xFF082739); // Gradient Start
const Color gradientMiddleColor1 = Color(0xFF020F38); // Gradient Middle 1
const Color gradientMiddleColor2 = Color(0xFF2F29AE); // Gradient Middle 2
const Color gradientEndColor = Color(0xFF4562E7); // Gradient End
// const Color lightWhite = Color(0xfff5f5f5); // Gradient End
const Color lightWhite = Color(0xfff8f8ff); // Gradient End
bool getIsDarkMode() {
  return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
}
Color textColor(BuildContext context){
  return isDarkMode(context)? Colors.white : Colors.black87;
}
Color hintColor(BuildContext context){
  return isDarkMode(context)? Colors.white70 : Colors.black54;
}
Color borderColor(BuildContext context){
  return isDarkMode(context)? Colors.white70 : neutralMediumGrey;
}
Color takePicture(BuildContext context){
  return isDarkMode(context)? Colors.green : Colors.lightGreen;
}
Color impoPicture(BuildContext context){
  return isDarkMode(context)? Colors.blue : Colors.lightBlue;
}




