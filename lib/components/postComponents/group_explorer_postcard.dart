import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';

import '../../themes/dark_light_switch.dart';
import '../dynamicScreenSize.dart';
import '../mydate.dart';
import 'options.dart';

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
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: (){
        showCustomMenu(context);
      },
      child: SizedBox(
        height: 290,
        child: Card(
          color: isDarkMode(context)?primaryDarkBlue.withValues(alpha: 0.6):neutralLightGrey.withValues(alpha: 0.6),
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
