import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../themes/colors.dart';
import '../postComponents/gridPostShimmar.dart';
import '../postComponents/group_explorer_postcard.dart';
import '../../Screens/home_screens/group_details_post_screen.dart';
import '../../apis/APIs.dart';
import '../isDarkMode.dart';

Widget travelPostsGrid(BuildContext context, [String? userId]) {
  final String targetUserId = userId ?? Apis.uid;
  
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('travel_posts')
        .where('createdBy', isEqualTo: targetUserId)
        .orderBy('createdAt', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return gridShimmar();
      }
      if (snapshot.hasError) {
        return const Center(child: Text("Error loading travel groups"));
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text("No travel groups found"));
      }

      // Map Firestore documents into a list of posts
      final List<Map<String, dynamic>> allPosts = snapshot.data!.docs
          .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: allPosts.length,
        itemBuilder: (context, index) {
          final postData = allPosts[index];
          final List<dynamic> destinations = postData['destinations'] ?? [];
          final String firstDestination = destinations.isNotEmpty ? destinations[0].toString() : 'Unknown';
          final double budget = double.tryParse(postData['budget']?.toString() ?? '0') ?? 0.0;
          final int duration = int.tryParse(postData['duration']?.toString() ?? '0') ?? 0;
          final int travelers = int.tryParse(postData['travelersCount']?.toString() ?? '0') ?? 0;
          final String genderPreference = postData['genderPreference']?.toString() ?? '';
          final String createdBy = postData['createdBy']?.toString() ?? '';
          final String postId = postData['id']?.toString() ?? '';
          final String groupId = postData['groupId']?.toString() ?? '';
          final Timestamp time = postData['createdAt'] as Timestamp? ?? Timestamp.now();

          return GroupExplorerPostCard(
            time: time,
            destination: firstDestination,
            budget: budget,
            duration: duration,
            travelers: travelers,
            genderPreference: genderPreference,
            itinerary: postData['itinerary']?.toString() ?? '',
            preferredAge: postData['preferredAge']?.toString() ?? '',
            accommodation: postData['accommodation']?.toString() ?? '',
            transportation: postData['transportation']?.toString() ?? '',
            organizerName: postData['organizerName']?.toString() ?? '',
            contactInfo: postData['contactInfo']?.toString() ?? '',
            socialMediaHandle: postData['socialMediaHandle']?.toString() ?? '',
            travelInterests: postData['travelInterests']?.toString() ?? '',
            experienceLevel: postData['experienceLevel']?.toString() ?? '',
            emergencyContact: postData['emergencyContact']?.toString() ?? '',
            healthRestrictions: postData['healthRestrictions']?.toString() ?? '',
            createdBy: createdBy,
            creatorName: Apis.me.name,
            postId: postId,
            groupId: groupId,
          );
        },
      );
    },
  );
} 