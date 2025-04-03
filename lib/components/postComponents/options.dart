import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Screens/home_screens/edit_group_post_screen.dart';
import '../../themes/colors.dart';
import '../dynamicScreenSize.dart';
import '../../apis/APIs.dart';
import '../chatComponents/Chatusermodel.dart';

void showCustomMenu(BuildContext context, String postId) {
  final currentUser = FirebaseAuth.instance.currentUser;
  
  Future<void> addToFavorites() async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add favorites')),
      );
      return;
    }

    try {
      // Reference to the user's favorites collection
      final userFavoritesRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('Favorites');

      // Check if already in favorites
      final docSnapshot = await userFavoritesRef.doc(postId).get();
      
      if (docSnapshot.exists) {
        // If already in favorites, remove it
        await userFavoritesRef.doc(postId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from favorites')),
        );
      } else {
        // Add to favorites with timestamp
        await userFavoritesRef.doc(postId).set({
          'postId': postId,
          'addedAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to favorites')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
    Navigator.pop(context); // Close the menu after action
  }

  // Check if current user is the creator of the post
  Future<bool> isCreator() async {
    if (currentUser == null) return false;
    try {
      final postDoc = await FirebaseFirestore.instance
          .collection('travel_posts')
          .doc(postId)
          .get();
      return postDoc.exists && postDoc.data()?['createdBy'] == currentUser.uid;
    } catch (e) {
      return false;
    }
  }

  // Check if users are friends
  Future<bool> isFriend(String creatorId) async {
    if (currentUser == null) return false;
    try {
      return await Apis.isFriend(currentUser.uid, creatorId);
    } catch (e) {
      print('Error checking friend status: $e');
      return false;
    }
  }

  // Send friend request using Apis method
  Future<void> sendFriendRequest(String creatorId) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to send friend requests')),
      );
      return;
    }

    try {
      // Get the recipient's user data to create ChatUser object
      final recipientDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(creatorId)
          .get();
      
      if (!recipientDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      final userData = recipientDoc.data()!;
      final chatUser = ChatUser(
        id: creatorId,
        name: userData['FullName'] ?? '',
        email: userData['Email'] ?? '',
        about: userData['About'] ?? '',
        image: userData['Image'] ?? '',
        createdAt: userData['CreatedAt'] ?? Timestamp.now(),
        isOnline: userData['isOnline'] ?? false,
        lastActive: userData['lastActive'] ?? Timestamp.now(),
        pushToken: userData['pushToken'] ?? '',
        username: userData['Username'] ?? '',
        Phone: userData['Phone'] ?? ''
      );

      // Create entry in current user's Friends_List
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .collection('Friends_List')
          .doc(creatorId)
          .set({
        'friendId': creatorId,
        'userAdded': false,
      });

      // Create entry in recipient's Friends_List
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(creatorId)
          .collection('Friends_List')
          .doc(currentUser.uid)
          .set({
        'friendId': currentUser.uid,
        'userAdded': false,
      });

      // Send the friend request using existing API method
      await Apis.sentFriendRequest(chatUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending friend request: ${e.toString()}')),
      );
    }
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Menu",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0, bottom: 200.0),
            child: Material(
              color: Colors.white.withValues(alpha: 0.0),
              borderRadius: BorderRadius.circular(12.0),
              elevation: 5.0,
              child: FutureBuilder<bool>(
                future: isCreator(),
                builder: (context, isCreatorSnapshot) {
                  if (!isCreatorSnapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final isCreator = isCreatorSnapshot.data!;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('travel_posts')
                        .doc(postId)
                        .get(),
                    builder: (context, postSnapshot) {
                      if (!postSnapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final creatorId = postSnapshot.data!.get('createdBy') as String;

                      return FutureBuilder<bool>(
                        future: isFriend(creatorId),
                        builder: (context, isFriendSnapshot) {
                          if (!isFriendSnapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final isFriend = isFriendSnapshot.data!;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMenuItem(
                                context: context,
                                icon: Icon(CupertinoIcons.star_circle_fill, color: PrimaryColor, size: 35),
                                label: "Add to favorites",
                                onTap: addToFavorites,
                              ),
                              if (isCreator) // Only show edit option to creator
                                _buildMenuItem(
                                  context: context,
                                  icon: Icon(CupertinoIcons.pencil_circle_fill, color: PrimaryColor, size: 35),
                                  label: "Edit",
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditGroupPostScreen(postId: postId),
                                      ),
                                    );
                                  },
                                ),
                              if (!isCreator && !isFriend) // Show friend request option only if not creator and not friends
                                _buildMenuItem(
                                  context: context,
                                  icon: Icon(CupertinoIcons.person_add, color: PrimaryColor, size: 35),
                                  label: "Send Friend Request",
                                  onTap: () => sendFriendRequest(creatorId),
                                ),
                              _buildMenuItem(
                                context: context,
                                icon: Icon(CupertinoIcons.profile_circled, color: PrimaryColor, size: 35),
                                label: "About this account",
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              _buildMenuItem(
                                context: context,
                                icon: Icon(CupertinoIcons.hand_thumbsdown_fill, color: Colors.orange, size: 35),
                                label: "Not interested",
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              if (isCreator) // Only show delete option to creator
                                _buildMenuItem(
                                  context: context,
                                  icon: Icon(CupertinoIcons.delete_solid, color: Colors.red, size: 35),
                                  label: "Delete",
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
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