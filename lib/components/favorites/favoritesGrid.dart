import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../postComponents/gridPostShimmar.dart';
import '../postComponents/group_explorer_postcard.dart';
import '../../apis/APIs.dart';
import '../isDarkMode.dart';
import '../postComponents/new_post.dart' as new_post;

Widget FavoritesGrid(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Users')
        .doc(Apis.uid)
        .collection('Favorites')
        .orderBy('addedAt', descending: true)
        .snapshots(),
    builder: (context, favSnapshot) {
      if (favSnapshot.connectionState == ConnectionState.waiting) {
        return gridShimmar();
      }

      if (favSnapshot.hasError) {
        return Center(child: Text('Error loading favorites'));
      }

      if (!favSnapshot.hasData || favSnapshot.data!.docs.isEmpty) {
        return Center(child: Text('No favorites yet'));
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: favSnapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final favoriteDoc = favSnapshot.data!.docs[index];
          final String postId = favoriteDoc['postId'] ?? '';

          if (postId.isEmpty) {
            return const SizedBox();
          }

          // First try to fetch from CommanPosts
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('CommanPosts')
                .doc(postId)
                .snapshots(),
            builder: (context, commonPostSnapshot) {
              if (commonPostSnapshot.hasData && commonPostSnapshot.data!.exists) {
                final postData = commonPostSnapshot.data!.data() as Map<String, dynamic>;
                final String userId = postData['userId'] ?? postData['createdBy'];
                if (userId != null && userId.isNotEmpty) {
                  postData['userId'] = userId;
                  postData['postId'] = postId;
                  
                  return FutureBuilder<Widget>(
                    future: new_post.PostCard(context, postData),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const SizedBox();
                      }
                      return snapshot.data ?? const SizedBox();
                    },
                  );
                }
                return const SizedBox();
              }

              // If not found in CommanPosts, try travel_posts
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('travel_posts')
                    .doc(postId)
                    .snapshots(),
                builder: (context, travelPostSnapshot) {
                  if (!travelPostSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!travelPostSnapshot.data!.exists) {
                    // If post doesn't exist in either collection, remove from favorites
                    if (!commonPostSnapshot.hasData || !commonPostSnapshot.data!.exists) {
                      FirebaseFirestore.instance
                          .collection('Users')
                          .doc(Apis.uid)
                          .collection('Favorites')
                          .doc(postId)
                          .delete();
                    }
                    return const SizedBox();
                  }

                  final postData = travelPostSnapshot.data!.data() as Map<String, dynamic>;
                  final String createdBy = postData['createdBy']?.toString() ?? '';

                  if (createdBy.isEmpty) {
                    return const SizedBox();
                  }

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(createdBy)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                      if (userData == null) {
                        return const SizedBox();
                      }

                      final String creatorName = userData['FullName'] ?? 'Unknown';
                      final String userImage = userData['Image'] ?? '';
                      
                      final List<dynamic> destinations = postData['destinations'] ?? [];
                      final String firstDestination = destinations.isNotEmpty ? destinations[0].toString() : 'Unknown';
                      final double budget = double.tryParse(postData['budget']?.toString() ?? '0') ?? 0.0;
                      final int duration = int.tryParse(postData['duration']?.toString() ?? '0') ?? 0;
                      final int travelers = int.tryParse(postData['travelersCount']?.toString() ?? '0') ?? 0;
                      final String genderPreference = postData['genderPreference']?.toString() ?? '';
                      final Timestamp time = postData['createdAt'] as Timestamp? ?? Timestamp.now();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: GroupExplorerPostCard(
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
                          creatorName: creatorName,
                          postId: postId,
                          groupId: postData['groupId']?.toString() ?? '',
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
} 