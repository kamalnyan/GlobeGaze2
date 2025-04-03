import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/Screens/home_screens/group_details_screen.dart';
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
  final String itinerary;
  final String preferredAge;
  final String accommodation;
  final String transportation;
  final String organizerName;
  final String contactInfo;
  final String socialMediaHandle;
  final String travelInterests;
  final String experienceLevel;
  final String emergencyContact;
  final String healthRestrictions;
  final String createdBy;
  final String creatorName;
  final String postId;

  const GroupExplorerPostCard({
    super.key,
    required this.time,
    required this.destination,
    required this.budget,
    required this.duration,
    required this.travelers,
    required this.genderPreference,
    this.itinerary = '',
    this.preferredAge = '',
    this.accommodation = '',
    this.transportation = '',
    this.organizerName = '',
    this.contactInfo = '',
    this.socialMediaHandle = '',
    this.travelInterests = '',
    this.experienceLevel = '',
    this.emergencyContact = '',
    this.healthRestrictions = '',
    required this.createdBy,
    required this.creatorName,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupDetailsScreen(
              time: time,
              destination: destination,
              budget: budget,
              duration: duration,
              travelers: travelers,
              genderPreference: genderPreference,
              itinerary: itinerary,
              preferredAge: preferredAge,
              accommodation: accommodation,
              transportation: transportation,
              organizerName: organizerName,
              contactInfo: contactInfo,
              socialMediaHandle: socialMediaHandle,
              travelInterests: travelInterests,
              experienceLevel: experienceLevel,
              emergencyContact: emergencyContact,
              healthRestrictions: healthRestrictions,
              createdBy: createdBy,
              creatorName: creatorName,
            ),
          ),
        );
      },
      onLongPress: () {
        showCustomMenu(context, postId);
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor(context)
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            MyDateUtil.getFormattedTimeStamp(context: context,timestamp: time),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: hintColor(context)
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person, size: 14, color: hintColor(context)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Created by $creatorName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: hintColor(context),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on, color: PrimaryColor),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoTile(context,Icons.attach_money, 'Budget', '\$${budget.toStringAsFixed(2)}'),
                          _buildInfoTile(context,Icons.calendar_today, 'Duration', '$duration Days'),
                        ],
                      ),
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
        Icon(icon, color: PrimaryColor, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, 
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500, 
                color: textColor(context)
              ),
            ),
            Text(value, 
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.bold,
                color: hintColor(context)
              ),
            ),
          ],
        ),
      ],
    );
  }
}
