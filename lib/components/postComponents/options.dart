import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../themes/colors.dart';
import '../dynamicScreenSize.dart';

void showCustomMenu(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Menu",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blurred background
        child: Align(
          alignment: Alignment.bottomRight, // Align to the bottom right
          child: Padding(
            padding: const EdgeInsets.only(
                right: 20.0, bottom: 200.0), // Position above FAB
            child: Material(
              color: Colors.white.withValues(alpha: 0.0), // Menu background
              borderRadius: BorderRadius.circular(12.0),
              elevation: 5.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuItem(
                    context: context,
                    icon:Icon(CupertinoIcons.star_circle_fill,color: PrimaryColor,size: 35,),
                    label: "Add to favorites",
                    onTap: () {

                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon:Icon(CupertinoIcons.pencil_circle_fill,color: PrimaryColor,size: 35,),
                    label: "Edit",
                    onTap: () {

                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon:Icon(CupertinoIcons.person_add,color: PrimaryColor,size: 35,),
                    label: "Follow",
                    onTap: () {

                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon:Icon(CupertinoIcons.profile_circled,color: PrimaryColor,size: 35,),
                    label: "About this account",
                    onTap: () {

                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon:Icon(CupertinoIcons.hand_thumbsdown_fill,color: Colors.orange,size: 35,),
                    label: "Not instrested",
                    onTap: () {

                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon:Icon(CupertinoIcons.delete_solid,color: Colors.red,size: 35,),
                    label: "Delete",
                    onTap: () {
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
Widget _buildMenuItem({
  required BuildContext context,
  required String label,
  required Icon icon,
  required VoidCallback onTap,
}) {
  final screenSize = getScreenSize(context);
  final textScaller = screenSize.shortestSide / 600;
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 39.0),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 25),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 30 * textScaller),
          ),
        ],
      ),
    ),
  );
}