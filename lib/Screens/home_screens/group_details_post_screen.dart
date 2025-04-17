import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/Screens/chat/messegescreen.dart';
import 'package:globegaze/components/chatComponents/Chatusermodel.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:line_icons/line_icons.dart';
import '../../screens/group_details_screen.dart';
import '../../themes/dark_light_switch.dart';
import '../../components/mydate.dart';

class GroupDetailsPostScreen extends StatefulWidget {
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
  final String groupId;

  const GroupDetailsPostScreen({
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
    required this.groupId,
  });

  @override
  State<GroupDetailsPostScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsPostScreen> {
  bool _isLoading = false;
  List<String> members = [];
  String groupName='';

  Future<void> getGroupMembers(String groupId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();
      if (doc.exists) {
        List<dynamic> membersList = doc.get('members');
        String name = doc.get('name') ?? 'Unnamed Group'; // Fetch the name field
        setState(() {
          groupName = name;
          members = membersList.cast<String>();
        });
      } else {
        print("Group not found");
        setState(() {
          members = [];
        });
      }
    } catch (e) {
      print("Error fetching members: $e");
      setState(() {
        members = [];
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    getGroupMembers(widget.groupId);
  }

  void _navigateToChat() async {
    if (widget.createdBy.isNotEmpty) {
      try {
          // Navigate to message screen
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupDetailsScreen(groupId: widget.groupId, groupName: groupName, members: members,),
              ),
            );
          }
      } catch (e) {
        _showSnackBar('Error connecting to chat: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: Text(
            'Group Details',
            style: TextStyle(
              color: textColor(context),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            )
        ),
        backgroundColor: isDarkMode(context) ? darkBackground : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // Add share functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeroSection(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                    const SizedBox(height: 80), // Space for bottom bar
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PrimaryColor.withOpacity(0.8),
            PrimaryColor.withOpacity(0.6),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(
            right: -30,
            top: -30,
            child: Icon(
              Icons.location_on,
              size: 180,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Icon(
              Icons.flight,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    MyDateUtil.getFormattedTimeStamp(context: context, timestamp: widget.time),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.destination,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "${widget.duration} days",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.person_outline, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "${widget.travelers} travelers",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: PrimaryColor,
                size: 32,
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
                    widget.creatorName,
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
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PrimaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.message_rounded,
                  color: PrimaryColor,
                  size: 20,
                ),
              ),
              onPressed: () async {
                if (widget.createdBy.isNotEmpty) {
                  _showSnackBar('Connecting to chat...');
                  _navigateToChat();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode(context) ? primaryDarkBlue.withOpacity(0.3) : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickInfoItem(context, Icons.attach_money_rounded, '\$${widget.budget.toStringAsFixed(0)}', 'Budget'),
          _buildDivider(context),
          _buildQuickInfoItem(context, Icons.calendar_month_rounded, '${widget.duration}', 'Days'),
          _buildDivider(context),
          _buildQuickInfoItem(context, Icons.group_rounded, '${widget.travelers}', 'Travelers'),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: isDarkMode(context) ? Colors.grey[700] : Colors.grey[300],
    );
  }

  Widget _buildQuickInfoItem(BuildContext context, IconData icon, String value, String label) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
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
        _buildInfoRow(context, Icons.wc_rounded, 'Gender Preference', widget.genderPreference),
        _buildInfoRow(context, Icons.person_outline_rounded, 'Preferred Age', widget.preferredAge),
        _buildInfoRow(context, Icons.hotel_rounded, 'Accommodation', widget.accommodation),
        _buildInfoRow(context, Icons.directions_car_rounded, 'Transportation', widget.transportation),
      ],
    );
  }

  Widget _buildOrganizerSection(BuildContext context) {
    return _buildSection(
      context,
      'Organizer Information',
      [
        _buildInfoRow(context, Icons.person_rounded, 'Organizer', widget.organizerName),
        _buildInfoRow(context, Icons.phone_rounded, 'Contact', widget.contactInfo),
        if (widget.socialMediaHandle.isNotEmpty)
          _buildInfoRow(context, Icons.link_rounded, 'Social Media', widget.socialMediaHandle),
      ],
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context) {
    return _buildSection(
      context,
      'Additional Information',
      [
        _buildInfoRow(context, Icons.description_rounded, 'Itinerary', widget.itinerary),
        _buildInfoRow(context, Icons.explore_rounded, 'Travel Interests', widget.travelInterests),
        _buildInfoRow(context, Icons.assessment_rounded, 'Experience Level', widget.experienceLevel),
        if (widget.emergencyContact.isNotEmpty)
          _buildInfoRow(context, Icons.emergency_rounded, 'Emergency Contact', widget.emergencyContact),
        if (widget.healthRestrictions.isNotEmpty)
          _buildInfoRow(context, Icons.medical_services_rounded, 'Health Restrictions', widget.healthRestrictions),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode(context) ? primaryDarkBlue.withOpacity(0.6) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                      title.contains('Trip') ? Icons.luggage_rounded :
                      title.contains('Organizer') ? Icons.badge_rounded :
                      Icons.info_outline_rounded,
                      color: PrimaryColor,
                      size: 22
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: PrimaryColor, size: 22),
          ),
          const SizedBox(width: 16),
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

  void _joinGroup() async {
    setState(() {
      _isLoading = true;
    });
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      await firestore.collection('groups').doc(widget.groupId).update({
        'members': FieldValue.arrayUnion([currentUser.uid]),
      });
      // Success notification
      if (mounted) {
        _showSnackBar('Successfully joined the group!');
        await getGroupMembers(widget.groupId);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to join group: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    // Get current user ID
    final currentUser = FirebaseAuth.instance.currentUser;
    final String currentUserId = currentUser?.uid ?? '';

    // Check if user is already a member using the members list properly populated in initState
    final bool isUserMember = members.contains(currentUserId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDarkMode(context) ? primaryDarkBlue : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : isUserMember
                  ? _navigateToChat
                  : _joinGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: PrimaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: PrimaryColor.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      isUserMember
                          ? LineIcons.facebookMessenger
                          : Icons.group_add_rounded,
                      size: 22
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isUserMember
                        ? 'Message Group'
                        : 'Join Group',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}