import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/Screens/login_signup_screens/verifyemail.dart';
import 'package:globegaze/firebase/login_signup_methods/username.dart';
import '../../components/AlertDilogbox.dart';
import '../../themes/colors.dart';
import '../usermodel/usermodel.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> signUpWithEmailPassword({
    required String fullName,
    required String email,
    required String about,
    required String image,
    required String phone,
    required String password,
    required bool isOnline,
    required String lastActive,
    required String pushToken,
    required bool isUerAdded,
    required BuildContext context
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password,);
      final users = userCredential.user;
      final username = trimBeforeAt(email);
      if (users != null) {
        final uid = users.uid;
        UserModel user = UserModel(
          id: uid,
          fullName: fullName,
          email: email,
          about: about,
          image: image,
          phone: phone,
          username: username,
          isOnline: false,
          lastActive: Timestamp.now(),
          pushToken: '',
          createdAt: Timestamp.now(),
          userAdded: true,
        );
        await _firestore.collection('Users').doc(uid).set(user.toJson());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created Scuessfully'),
            backgroundColor: PrimaryColor,),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> VerifyEmailScreen(email)));
      }
    }on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        AlertDialogBox(context: context,animationType: CoolAlertType.error,message: "The password provided is too weak.",title: "Error");
      } else if (e.code == 'email-already-in-use') {
        AlertDialogBox(context: context,animationType: CoolAlertType.error,message: "The account already exists for that email.",title: "Error");
      } else if (e.code == 'invalid-email') {
        AlertDialogBox(context: context,animationType: CoolAlertType.error,message: "The email address is badly formatted.",title: "Error");
      } else if (e.code == 'operation-not-allowed') {
        AlertDialogBox(context: context,animationType: CoolAlertType.error,message: "Signing in with Email and Password is not enabled.",title: "Error");
      } else {
        AlertDialogBox(context: context,animationType: CoolAlertType.error,message: "An unexpected error occurred: ${e.message}",title: "Error");
      }
    } catch (e) {
      AlertDialogBox(context: context,animationType: CoolAlertType.error,message: "An unexpected error occurred: ${e.toString()}",title: "Error");
    }
  }
}

