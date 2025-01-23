import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';
Future AlertDialogBox({required BuildContext context,required CoolAlertType animationType ,
  required String message ,required String title}) {
  return CoolAlert.show(
    context: context,
    type: animationType,
    text: message,
    title: title,

    // icon's Background
    confirmBtnColor: PrimaryColor, // ok button color
    titleTextStyle: const TextStyle(color: Colors.orange,fontSize: 23),
    backgroundColor: PrimaryColor,
  );
}
