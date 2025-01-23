
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
            color: PrimaryColor.withOpacity(0.1),
          ),
          child: Icon(icon, color: PrimaryColor),
        ),
      ),
      Expanded(
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color:isDarkMode(context)? Color(0xFF343434):Color(0xFF888888),
            borderRadius: BorderRadius.circular(22.0),
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            cursorColor: PrimaryColor,
            style: TextStyle(
              color: isDarkMode(context) ? Colors.white : Colors.black,
              decoration: TextDecoration.none,
            ),
            decoration: null,
            maxLines: 1,
          ),
        ),
      ),
    ],
  );
}
