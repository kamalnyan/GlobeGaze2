import 'package:flutter/material.dart';

import 'dynamicScreenSize.dart';

Widget buildButton({
  required BuildContext context,
  required String text,
  required Color textColor,
  required VoidCallback onTap,
  Color? bgColor,
  List<Color>? gradientColors,
}) {
  final screenSize = getScreenSize(context);
  final textScaleFactor = screenSize.shortestSide/ 600;
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(25),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: gradientColors == null ? bgColor : null,
        gradient: gradientColors != null
            ? LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 28 * textScaleFactor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
