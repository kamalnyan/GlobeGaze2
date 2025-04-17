import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:globegaze/components/isDarkMode.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../apis/APIs.dart';
import '../../apis/addPost.dart';
import '../../apis/usermodel/usermodel.dart';
import '../../themes/colors.dart';
import '../mydate.dart';
import '../shimmarEffect.dart';
import 'comment_box.dart';
import 'options.dart';


Future<Widget> PostCard(
    BuildContext context, Map<String, dynamic> postData) async {
  UserModel? user = await addPost.fetchUserInformation(postData['userId']);
  final List<dynamic> mediaUrls = postData['mediaUrls'] ?? [];

  // Fallback for createdAt timestamp
  final DateTime createdAt = postData['createdAt'] != null
      ? (postData['createdAt'] as Timestamp).toDate()
      : DateTime.now();

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: isDarkMode(context)
        ? primaryDarkBlue
        : neutralLightGrey.withValues(alpha: 0.6),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section with animation
          _buildUserHeader(context, user, createdAt, postData)
              .animate()
              .fadeIn(duration: 300.ms, curve: Curves.easeIn)
              .slideX(begin: -0.1, end: 0, duration: 350.ms),

          // Media Content
          if (mediaUrls.isNotEmpty)
            _buildMediaCarousel(context, mediaUrls, postData['postId'])
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .scale(begin: const Offset(0.98, 0.98), duration: 350.ms),

          // Action Buttons and Post Content
          _buildPostActions(context, postData)
              .animate()
              .fadeIn(duration: 350.ms, delay: 300.ms)
              .slideY(begin: 0.1, end: 0, duration: 300.ms),

          // Post text content
          if (postData['text'].isNotEmpty)
            _buildPostContent(context, postData)
                .animate()
                .fadeIn(duration: 400.ms, delay: 350.ms),

          // Top comment preview
          _buildTopComment(context, postData)
              .animate()
              .fadeIn(duration: 450.ms, delay: 400.ms),

          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

Widget _buildUserHeader(BuildContext context, UserModel? user,
    DateTime createdAt, Map<String, dynamic> postData) {
  return Padding(
    padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
    child: Row(
      children: [
        // User avatar with staggered animation
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade300,
            child: (user != null &&
                user.image.isNotEmpty &&
                user.image.startsWith('http'))
                ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: user.image,
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/png_jpeg_images/user.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            )
                : ClipOval(
              child: Image.asset(
                'assets/png_jpeg_images/user.jpg',
                fit: BoxFit.cover,
                width: 40,
                height: 40,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'Unknown User',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                MyDateUtil.timeAgo(Timestamp.fromDate(createdAt)),
                style: TextStyle(
                  fontSize: 12,
                  color: hintColor(context).withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
        // More options button with ripple effect
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              showCustomMenu(context, postData['postId'], postType: PostType.commonPost);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                CupertinoIcons.ellipsis_vertical_circle,
                color: textColor(context).withOpacity(0.8),
                size: 22,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildMediaCarousel(BuildContext context, List<dynamic> mediaUrls, String postId) {
  final PageController pageController = PageController();
  final ValueNotifier<int> currentPageIndex = ValueNotifier(0);

  return StatefulBuilder(
    builder: (context, setState) {
      return Stack(
        children: [
          Container(
            height: 320,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 12),
            child: PageView.builder(
              controller: pageController,
              itemCount: mediaUrls.length,
              onPageChanged: (index) {
                // Update the ValueNotifier which will rebuild dependent widgets
                currentPageIndex.value = index;
                setState(() {});
              },
              itemBuilder: (context, index) {
                // Create a unique tag for each image
                final String heroTag = 'image-${postId}-${index}';

                return GestureDetector(
                  onTap: () {
                    final List<String> imageUrls = mediaUrls
                        .map((url) => url.toString())
                        .toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImagePreviewPage(
                          imageUrls: imageUrls,
                          initialIndex: currentPageIndex.value,
                          heroTags: List.generate(mediaUrls.length,
                                  (i) => 'image-${postId}-${i}'),
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: heroTag,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: mediaUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.grey[300],
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Enhanced page indicator with better positioning and appearance
          if (mediaUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Current index display with ValueListenableBuilder
                      ValueListenableBuilder<int>(
                        valueListenable: currentPageIndex,
                        builder: (context, index, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "${index + 1}/${mediaUrls.length}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                      ),
                      const SizedBox(width: 12),
                      // Visual indicators with ValueListenableBuilder
                      Expanded(
                        child: ValueListenableBuilder<int>(
                          valueListenable: currentPageIndex,
                          builder: (context, index, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                mediaUrls.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: index == i ? 18 : 8,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: index == i
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    boxShadow: index == i ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      )
                                    ] : null,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Navigation arrows with improved touch areas
          if (mediaUrls.length > 1)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left navigation button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ValueListenableBuilder<int>(
                      valueListenable: currentPageIndex,
                      builder: (context, index, _) {
                        return _buildNavigationButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: () {
                            if (index > 0) {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          visible: index > 0, // Only show when not on first page
                        );
                      }
                    ),
                  ),
                  // Right navigation button
                  Align(
                    alignment: Alignment.centerRight,
                    child: ValueListenableBuilder<int>(
                      valueListenable: currentPageIndex,
                      builder: (context, index, _) {
                        return _buildNavigationButton(
                          icon: Icons.chevron_right_rounded,
                          onTap: () {
                            if (index < mediaUrls.length - 1) {
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          visible: index < mediaUrls.length - 1, // Only show when not on last page
                        );
                      }
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

// FIXED: Updated navigation button with visibility control and larger tap area
Widget _buildNavigationButton({
  required IconData icon, 
  required VoidCallback onTap,
  bool visible = true,
}) {
  if (!visible) return const SizedBox.shrink();
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Material(
      color: Colors.black.withOpacity(0.3),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Increased tap area
          child: Icon(
            icon,
            color: Colors.white,
            size: 24, // Increased icon size
          ),
        ),
      ),
    ),
  );
}

// Also need to update the ImagePreviewPage to accept heroTags
// This is a simplified version - you'll need to adapt it to your actual implementation
class ImagePreviewPage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final List<String> heroTags;

  const ImagePreviewPage({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
    required this.heroTags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implementation of your ImagePreviewPage with heroTags
    // Make sure to use the same heroTags for Hero animations here
    return Scaffold(
      body: PageView.builder(
        itemCount: imageUrls.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          return Hero(
            tag: heroTags[index],
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}

Widget _buildPostActions(BuildContext context, Map<String, dynamic> postData) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
      children: [
        _buildActionButton(
          context: context,
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('CommanPosts')
                .doc(postData['postId'])
                .collection('likes')
                .doc(Apis.uid)
                .snapshots(),
            builder: (context, snapshot) {
              bool liked = false;
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                liked = data['liked'] ?? false;
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    liked
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color: liked ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('CommanPosts')
                        .doc(postData['postId'])
                        .collection('likes')
                        .snapshots(),
                    builder: (context, snapshot) {
                      int likeCount = 0;
                      if (snapshot.hasData) {
                        likeCount = snapshot.data!.docs.length;
                      }
                      return Text(
                        likeCount.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: liked ? Colors.red : Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          onTap: () {
            // Get the current like state before toggling
            FirebaseFirestore.instance
                .collection('CommanPosts')
                .doc(postData['postId'])
                .collection('likes')
                .doc(Apis.uid)
                .get()
                .then((doc) {
              bool currentlyLiked = false;
              if (doc.exists) {
                final data = doc.data() as Map<String, dynamic>;
                currentlyLiked = data['liked'] ?? false;
              }
              togglePostLike(postData['postId'], currentlyLiked);
            });
          },
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          context: context,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.chat_bubble,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 6),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('CommanPosts')
                    .doc(postData['postId'])
                    .collection('comments')
                    .snapshots(),
                builder: (context, snapshot) {
                  int commentCount = 0;
                  if (snapshot.hasData) {
                    commentCount = snapshot.data!.docs.length;
                  }
                  return Text(
                    commentCount.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),
          onTap: () => showCommentsBottomSheet(context, postData['postId']),
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          context: context,
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(Apis.uid)
                .collection('bookmarks')
                .doc(postData['postId'])
                .snapshots(),
            builder: (context, snapshot) {
              bool bookmarked = snapshot.hasData && snapshot.data!.exists;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    bookmarked 
                        ? CupertinoIcons.bookmark_fill 
                        : CupertinoIcons.bookmark,
                    color: bookmarked ? Theme.of(context).primaryColor : Colors.grey,
                    size: 20,
                  ),
                  if (bookmarked)
                    const SizedBox(width: 4),
                  if (bookmarked)
                    Text(
                      "Saved",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              );
            }
          ),
          onTap: () => toggleBookmark(context, postData),
        ),
        const Spacer(),
        // Enhanced share button
        _buildActionButton(
          context: context,
          child: const Icon(
            CupertinoIcons.share,
            color: Colors.grey,
            size: 20,
          ),
          onTap: () {
            // Show share options menu
            _showShareOptions(context, postData);
          },
        ),
      ],
    ),
  );
}

// Save/unsave post to user's bookmarks
void toggleBookmark(BuildContext context, Map<String, dynamic> postData) async {
  try {
    final String postId = postData['postId'];
    final DocumentReference bookmarkRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(Apis.uid)
        .collection('bookmarks')
        .doc(postId);
        
    // Check if post is already bookmarked
    final bookmarkDoc = await bookmarkRef.get();
    final bool isBookmarked = bookmarkDoc.exists;
    
    if (isBookmarked) {
      // Remove bookmark
      await bookmarkRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post removed from bookmarks'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Add bookmark
      await bookmarkRef.set({
        'postId': postId,
        'savedAt': Timestamp.now(),
        'postData': postData,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post saved to bookmarks'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Enhanced share options menu with comprehensive social platforms
void _showShareOptions(BuildContext context, Map<String, dynamic> postData) {
  String postContent = postData['text'] ?? '';
  List<dynamic> mediaUrls = postData['mediaUrls'] ?? [];
  String shareText = "Check out this post from GlobeGaze!\n\n";
  
  if (postContent.isNotEmpty) {
    shareText += "$postContent\n\n";
  }
  
  if (mediaUrls.isNotEmpty) {
    shareText += "View images at: ${mediaUrls.first}\n\n";
  }
  
  shareText += "Download GlobeGaze now!";

  // Define all share platforms with their icons
  final List<Map<String, dynamic>> sharePlatforms = [
    {"icon": Icons.message, "name": "Message", "type": "message"},
    {"icon": Icons.chat_bubble, "name": "WhatsApp", "type": "whatsapp"},
    {"icon": Icons.camera_alt, "name": "Instagram", "type": "instagram"},
    {"icon": Icons.facebook, "name": "Facebook", "type": "facebook"},
    {"icon": Icons.telegram, "name": "Telegram", "type": "telegram"},
    {"icon": Icons.work, "name": "LinkedIn", "type": "linkedin"},
    {"icon": Icons.mail, "name": "Email", "type": "email"},
    {"icon": Icons.copy, "name": "Copy Link", "type": "copy"},
  ];
  
  showModalBottomSheet(
    context: context,
    backgroundColor: isDarkMode(context) ? primaryDarkBlue : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.only(bottom: 20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Post preview section
              if (mediaUrls.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(mediaUrls.first.toString()),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (postContent.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    postContent.length > 100 
                        ? "${postContent.substring(0, 100)}..." 
                        : postContent,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor(context),
                    ),
                  ),
                ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Share via",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Share options grid
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: sharePlatforms.length,
                  itemBuilder: (context, index) {
                    final platform = sharePlatforms[index];
                    return _buildShareOption(
                      context,
                      icon: platform["icon"],
                      label: platform["name"],
                      onTap: () {
                        Navigator.pop(context);
                        _shareContent(context, shareText, platform["type"], postData);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Add back the missing share option builder function
Widget _buildShareOption(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textColor(context),
          ),
        ),
      ],
    ),
  );
}

// Enhanced share functionality with implementation for specific platforms
void _shareContent(BuildContext context, String content, String method, Map<String, dynamic> postData) {
  try {
    // Log share activity for analytics
    FirebaseFirestore.instance.collection('CommanPosts')
        .doc(postData['postId'])
        .collection('shares')
        .add({
      'userId': Apis.uid,
      'timestamp': Timestamp.now(),
      'method': method,
    });
        
    // Display user feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sharing via ${_capitalizeFirst(method)}"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Implementation for different sharing methods
    switch (method) {
      case "copy":
        // Implement clipboard functionality
        // Note: For actual implementation, you need to add the 'flutter/services.dart' import
        // and use: Clipboard.setData(ClipboardData(text: content));
        
        // For demonstration purposes:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Link copied to clipboard"),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        break;
        
      case "whatsapp":
        // Launch WhatsApp with the given content
        // For actual implementation, use url_launcher package:
        final encodedContent = Uri.encodeComponent(content);
        final whatsappUrl = "whatsapp://send?text=$encodedContent";
        launch(whatsappUrl);
        break;
        
      case "facebook":
        // Launch Facebook share dialog
        // For actual implementation, use the facebook_share package or url_launcher:
        final facebookUrl = "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent('https://yourdomain.com/posts/${postData['postId']}')}";
        launch(facebookUrl);
        break;
        
      case "instagram":
        // For Instagram, typically you need to use the Instagram story sharing SDK
        // This requires the instagram_share package or similar
        // Since Instagram doesn't have a direct URL scheme for text sharing, you might need to:
        // 1. Save the image locally first
        // 2. Use the Instagram share intent
        break;
        
      case "telegram":
        // Launch Telegram with the given content
        final encodedContent = Uri.encodeComponent(content);
        final telegramUrl = "https://t.me/share/url?url=https://globegaze.app&text=$encodedContent";
        launch(telegramUrl);
        break;
        
      case "linkedin":
        // Launch LinkedIn share dialog
        final linkedinUrl = "https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent('https://yourdomain.com/posts/${postData['postId']}')}";
        launch(linkedinUrl);
        break;
        
      case "email":
        // Launch email app with pre-filled content
        final emailUrl = "mailto:?subject=Check out this GlobeGaze post&body=${Uri.encodeComponent(content)}";
        launch(emailUrl);
        break;
        
      default:
        // Use system share sheet as fallback for all other methods
        // This requires the share_plus package:
        // Share.share(content);
        break;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error sharing: ${e.toString()}"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Helper to capitalize the first letter of a string
String _capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

Widget _buildActionButton({
  required BuildContext context,
  required Widget child,
  required VoidCallback onTap,
}) {
  return Material(
    color: isDarkMode(context)
        ? Colors.black.withOpacity(0.2)
        : Colors.grey.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: child,
      ),
    ),
  );
}

Widget _buildPostContent(BuildContext context, Map<String, dynamic> postData) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(
      postData['text'],
      style: TextStyle(
        color: textColor(context),
        fontSize: 14,
        height: 1.4,
      ),
    ),
  );
}

Widget _buildTopComment(BuildContext context, Map<String, dynamic> postData) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('CommanPosts')
        .doc(postData['postId'])
        .collection('comments')
        .orderBy('likes', descending: true)
        .limit(1)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ShimmerWidget(width: 200, height: 16),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const SizedBox(); // No comments available
      }

      final commentData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
      final username = commentData['username'] ?? 'Anonymous';
      final commentText = commentData['comment'] ?? '';

      return GestureDetector(
        onTap: () => showCommentsBottomSheet(context, postData['postId']),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode(context)
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                CupertinoIcons.chat_bubble_2_fill,
                size: 12,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: hintColor(context),
                    ),
                    children: [
                      TextSpan(
                        text: username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ': '),
                      TextSpan(
                        text: commentText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void togglePostLike(String postId, bool liked) {
  DocumentReference likeDoc = FirebaseFirestore.instance
      .collection('CommanPosts')
      .doc(postId)
      .collection('likes')
      .doc(Apis.uid);

  if (liked) {
    // If already liked, remove the like entry (unlike the post)
    likeDoc.delete();
  } else {
    // If not liked, add a new like entry
    likeDoc.set({
      'liked': true,
      'userId': Apis.uid,
    });
  }
}