import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

ThemeData lightTheme = ThemeData(
  primaryColor: primaryDarkBlue,
  scaffoldBackgroundColor: Colors.white,
  hintColor: primaryBrightCyan,
  cardColor: Colors.white,
  dividerColor: neutralMediumGrey,
  textTheme: TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.deepPurple),
    titleLarge: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black87),
    bodyLarge: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
    bodyMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey[700]),
    labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey[600]),
    displayMedium: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.redAccent),
  ),
);

ThemeData darkTheme = ThemeData(
  primaryColor: primaryBrightCyan,
  scaffoldBackgroundColor: darkBackground,
  cardColor: darkCardColor,
  hintColor: accentGoldenYellow,
  dividerColor: darkDivider,
  textTheme: TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.deepPurple),
    titleLarge: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black87),
    bodyLarge: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
    bodyMedium: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey[700]),
    labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey[600]),
    displayMedium: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.redAccent),
  ),
);
void setStatusBarColor(Color color, Brightness iconBrightness) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: color,         // Color of the status bar
      statusBarIconBrightness: iconBrightness,  // Icons' brightness
    ),
  );
}