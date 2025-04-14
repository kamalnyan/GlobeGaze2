import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globegaze/Screens/home_screens/group_details_post_screen.dart';
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
    required String groupId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode(context);
    final size = MediaQuery.of(context).size;
    final cardBackground = isDark
        ? Color(0xFF1A2235)
        : Colors.white;
    final cardBorderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.withOpacity(0.12);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => GroupDetailsPostScreen(
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
                groupId: 'tVivetRtTX5xx6avqpJn',
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 0.05);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: FadeTransition(opacity: animation, child: child));
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        },
        onLongPress: () {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final position = box.localToGlobal(Offset.zero);

          // Add haptic feedback
          HapticFeedback.mediumImpact();

          showCustomMenu(context, postId, postType: PostType.travelPost);
        },
        child: Container(
          height: 390,
          width: double.infinity,
          child: Stack(
            children: [
              // Card background with glass effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      if (!isDark) BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: cardBorderColor, width: isDark ? 1 : 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: isDark ? BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ) : null,
                  ),
                ),
              ),

              // Header background with destination image (placeholder gradient)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 140,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        PrimaryColor.withOpacity(0.9),
                        PrimaryColor.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),

              // Hero destination icon
              Positioned(
                right: 20,
                top: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.explore_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              // Header content
              Positioned(
                top: 20,
                left: 24,
                right: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            destination,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            MyDateUtil.getFormattedTimeStamp(context: context, timestamp: time),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Creator information
              Positioned(
                top: 100,
                left: 24,
                right: 24,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: PrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        creatorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.group,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$travelers',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureRow(
                        context,
                        [
                          _buildFeature(
                            context,
                            Icons.attach_money,
                            '\$${budget.toStringAsFixed(0)}',
                            'Budget',
                            PrimaryColor,
                          ),
                          _buildFeature(
                            context,
                            Icons.calendar_today,
                            '$duration Days',
                            'Duration',
                            Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureRow(
                        context,
                        [
                          _buildFeature(
                            context,
                            Icons.wc,
                            genderPreference.isEmpty ? 'Any' : genderPreference,
                            'Gender',
                            Colors.purple,
                          ),
                          _buildFeature(
                            context,
                            Icons.hotel,
                            accommodation.isEmpty ? 'Not specified' : accommodation,
                            'Accommodation',
                            Colors.teal,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GroupDetailsPostScreen(
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
                                      groupId: 'tVivetRtTX5xx6avqpJn',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined),
                              label: const Text('View Details'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PrimaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, List<Widget> children) {
    return Row(
      children: children.map((child) => Expanded(child: child)).toList(),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String value, String label, Color iconColor) {
    final isDark = isDarkMode(context);
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.2)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}