import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';
import '../../themes/dark_light_switch.dart';
import '../../components/mydate.dart';

class GroupDetailsScreen extends StatelessWidget {
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

  const GroupDetailsScreen({
    super.key,
    required this.time,
    required this.destination,
    required this.budget,
    required this.duration,
    required this.travelers,
    required this.genderPreference,
    required this.itinerary,
    required this.preferredAge,
    required this.accommodation,
    required this.transportation,
    required this.organizerName,
    required this.contactInfo,
    required this.socialMediaHandle,
    required this.travelInterests,
    required this.experienceLevel,
    required this.emergencyContact,
    required this.healthRestrictions,
    required this.createdBy,
    required this.creatorName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? primaryDarkBlue : Colors.grey[50],
      appBar: AppBar(
        title: Text('Group Details', 
          style: TextStyle(
            color: textColor(context),
            fontWeight: FontWeight.bold,
          )
        ),
        backgroundColor: isDarkMode(context) ? primaryDarkBlue : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Add share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildQuickInfoSection(context),
                  const SizedBox(height: 24),
                  _buildCreatorSection(context),
                  const SizedBox(height: 24),
                  _buildInfoSection(context),
                  const SizedBox(height: 24),
                  _buildOrganizerSection(context),
                  const SizedBox(height: 24),
                  _buildAdditionalInfoSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: PrimaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Icon(
              Icons.location_on,
              size: 200,
              color: PrimaryColor.withOpacity(0.1),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  destination,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: PrimaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    MyDateUtil.getFormattedTimeStamp(context: context, timestamp: time),
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode(context) ? primaryDarkBlue.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: PrimaryColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Created by',
                    style: TextStyle(
                      fontSize: 14,
                      color: hintColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    creatorName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor(context),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.message,
                color: PrimaryColor,
              ),
              onPressed: () {
                // Add message functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickInfoItem(context, Icons.attach_money, '\$${budget.toStringAsFixed(2)}', 'Budget'),
        _buildQuickInfoItem(context, Icons.calendar_today, '$duration', 'Days'),
        _buildQuickInfoItem(context, Icons.group, '$travelers', 'Travelers'),
      ],
    );
  }

  Widget _buildQuickInfoItem(BuildContext context, IconData icon, String value, String label) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28, // 28% of screen width
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode(context) ? primaryDarkBlue.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: PrimaryColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor(context),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: hintColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return _buildSection(
      context,
      'Trip Information',
      [
        _buildInfoRow(context, Icons.male_outlined, 'Gender Preference', genderPreference),
        _buildInfoRow(context, Icons.calendar_today, 'Preferred Age', preferredAge),
        _buildInfoRow(context, Icons.hotel, 'Accommodation', accommodation),
        _buildInfoRow(context, Icons.directions_car, 'Transportation', transportation),
      ],
    );
  }

  Widget _buildOrganizerSection(BuildContext context) {
    return _buildSection(
      context,
      'Organizer Information',
      [
        _buildInfoRow(context, Icons.person, 'Organizer', organizerName),
        _buildInfoRow(context, Icons.phone, 'Contact', contactInfo),
        if (socialMediaHandle.isNotEmpty)
          _buildInfoRow(context, Icons.link, 'Social Media', socialMediaHandle),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context) {
    return _buildSection(
      context,
      'Additional Information',
      [
        _buildInfoRow(context, Icons.book, 'Itinerary', itinerary),
        _buildInfoRow(context, Icons.explore, 'Travel Interests', travelInterests),
        _buildInfoRow(context, Icons.assessment, 'Experience Level', experienceLevel),
        if (emergencyContact.isNotEmpty)
          _buildInfoRow(context, Icons.emergency, 'Emergency Contact', emergencyContact),
        if (healthRestrictions.isNotEmpty)
          _buildInfoRow(context, Icons.medical_services, 'Health Restrictions', healthRestrictions),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode(context) ? primaryDarkBlue.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor(context),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: PrimaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: hintColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode(context) ? primaryDarkBlue : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Add join group functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Join Group',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.message,
              color: PrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
} 