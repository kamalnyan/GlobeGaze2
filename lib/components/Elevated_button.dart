import 'package:flutter/material.dart';

Widget Button({onPress,text,fontSize,bgColor,fgColor}){
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
      ),
      onPressed: onPress, child: Text(text,style: TextStyle(fontSize: fontSize),));
}