import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';

import '../../themes/dark_light_switch.dart';
import '../dynamicScreenSize.dart';
import '../mydate.dart';

class GroupExplorerPostCard extends StatelessWidget {
  final String destination;
  final Timestamp time;
  final double budget;
  final int duration;
  final int travelers;
  final String genderPreference;

  const GroupExplorerPostCard({
    super.key,
    required this.time,
    required this.destination,
    required this.budget,
    required this.duration,
    required this.travelers,
    required this.genderPreference,
  });
  void _showCustomMenu(BuildContext context) {
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
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: (){
        _showCustomMenu(context);
      },
      child: SizedBox(
        height: 290,
        child: Card(
          color: isDarkMode(context)?primaryDarkBlue:neutralLightGrey.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          destination,
                          style:  TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor(context)
                          ),
                        ),
                        Text(
                          MyDateUtil.getFormattedTimeStamp(context: context,timestamp: time),
                          style:  TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: hintColor(context)
                          ),
                        ),
                      ]
                    ),
                    const Icon(Icons.location_on, color: PrimaryColor),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoTile(context,Icons.attach_money, 'Budget', '\$${budget.toStringAsFixed(2)}'),
                    _buildInfoTile(context,Icons.calendar_today, 'Duration', '$duration Days'),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoTile(context,Icons.group, 'Travelers', '$travelers People'),
                    _buildInfoTile(context,Icons.male_outlined, 'Gender', genderPreference.isEmpty?'Unknown':genderPreference),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context,IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: PrimaryColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style:  TextStyle(fontWeight: FontWeight.w500, color: textColor(context))),
            Text(value, style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: hintColor(context))),
          ],
        ),
      ],
    );
  }
}
