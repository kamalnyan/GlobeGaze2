import 'package:flutter/cupertino.dart';
bool isDarkMode(BuildContext context){
  return  MediaQuery.of(context).platformBrightness == Brightness.dark;
}