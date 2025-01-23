import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
Color darkLight(bool isDarkMode) {
  return isDarkMode ? Colors.black : Colors.white;
}
Color LightDark(bool isDarkMode) {
  return isDarkMode ? Colors.white : Colors.black;
}
Color LightDarkshade(bool isDarkMode) {
  return isDarkMode ? Color(0xff71797E) : Colors.black;
}
Color darkLightshade(bool isDarkMode) {
  return isDarkMode ? Colors.black54 : Colors.white;
}
bool isDarkMode(BuildContext context){
  var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
}