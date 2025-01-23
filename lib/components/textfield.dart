import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../themes/dark_light_switch.dart';

Widget customTextField({isDarkMode,name,icon,obs,keyboradType,controllerr}){
  return TextField(
    controller: controllerr,
    autocorrect: true,
    obscureText: obs,
    keyboardType: keyboradType,
    cursorColor: PrimaryColor,
    style: TextStyle(color: LightDark(isDarkMode)),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: PrimaryColor),
      label: Text(name,style: TextStyle(color: LightDark(isDarkMode)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13.0),
        borderSide: BorderSide(color: PrimaryColor),
      ),
    ),
  );
}
