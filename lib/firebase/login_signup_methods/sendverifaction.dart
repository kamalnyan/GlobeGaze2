import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../components/AlertDilogbox.dart';

Future<void> sendVerificationEmail(User user,BuildContext context) async {
  try {
    await user.sendEmailVerification();
    AlertDialogBox(title: "Verifaction",message: 'Verification email sent to ${user.email}',animationType: CoolAlertType.success,context: context);
  } catch (e) {
    AlertDialogBox(title: "Error",message: 'Error sending verification email',animationType: CoolAlertType.error,context: context);
  }
}
