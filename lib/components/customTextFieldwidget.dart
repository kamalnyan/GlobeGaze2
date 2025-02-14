
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../themes/colors.dart';
import '../themes/dark_light_switch.dart';

Widget buildProfileTextField(BuildContext context, {
  required TextEditingController controller,
  required IconData icon,
  required String placeholder,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color:isDarkMode(context)?primaryDarkBlue:neutralLightGrey.withValues(alpha: 0.6),
          ),
          child: Icon(icon, color: PrimaryColor),
        ),
      ),
      Expanded(
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color:isDarkMode(context)?primaryDarkBlue:neutralLightGrey.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(22.0),
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            placeholderStyle: TextStyle(
              color: hintColor(context), // Change this to your desired hint color
              fontSize: 16,
            ),
            cursorColor: PrimaryColor,
            style: TextStyle(
              color: textColor(context), // This controls the entered text color
              decoration: TextDecoration.none,
            ),
            decoration: null,
            maxLines: 1,
          ),
        ),
      )
    ],
  );
}
