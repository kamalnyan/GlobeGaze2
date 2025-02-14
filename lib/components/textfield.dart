import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../themes/dark_light_switch.dart';
import 'dynamicScreenSize.dart';

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

Widget customTextField1(
    {context,
      name,
      icon,
      obs,
      keyboradType,
      controllerr,
      isobs,
      onPressed}) {
  final screenSize = getScreenSize(context);
  final scallText = screenSize.shortestSide/600;
  final screenW = screenSize.width;
  final screenh = screenSize.height;
  return TextField(
    controller: controllerr,
    obscureText: obs,
    keyboardType: keyboradType,
    cursorColor: PrimaryColor,
    style: TextStyle(color: LightDark(isDarkMode(context))),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: PrimaryColor),
      label: Text(
        name,
        style: TextStyle(color: LightDark(isDarkMode(context)),fontSize: 26*scallText),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13.0),
        borderSide: const BorderSide(color: PrimaryColor),
      ),
      suffixIcon: IconButton(
        icon: isobs
            ?  Icon(CupertinoIcons.eye_slash,color: isDarkMode(context)?Colors.white:Colors.black)
            :  Icon(CupertinoIcons.eye,color:  isDarkMode(context)?Colors.white:Colors.black),
        onPressed: onPressed,
      ),
    ),
  );
}
