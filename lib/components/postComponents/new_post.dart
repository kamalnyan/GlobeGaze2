import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/components/isDarkMode.dart';

import '../../apis/APIs.dart';
import '../../apis/addPost.dart';
import '../../apis/usermodel/usermodel.dart';
import '../../themes/colors.dart';
import '../mydate.dart';
import '../shimmarEffect.dart';
import 'comment_box.dart';
import 'imagePreview.dart';
import 'options.dart';

Future<Widget> PostCard(
    BuildContext context, Map<String, dynamic> postData) async {
  UserModel? user = await addPost.fetchUserInformation(postData['userId']);
  final List<dynamic> mediaUrls = postData['mediaUrls'] ?? [];
  int currentIndex = 0;

  // Fallback for createdAt timestamp
  final DateTime createdAt = postData['createdAt'] != null
      ? (postData['createdAt'] as Timestamp).toDate()
      : DateTime.now();

  return Padding(
    padding: const EdgeInsets.only(top: 25.0, left: 7, right: 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Section
        ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundImage: (user != null &&
                    user.image.isNotEmpty &&
                    user.image.startsWith('http'))
                ? CachedNetworkImageProvider(user.image)
                : const AssetImage('assets/png_jpeg_images/user.jpg')
                    as ImageProvider,
            backgroundColor: Colors.grey.shade300,
          ),
          title: Text(
            user?.fullName ?? 'Unknown User',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: textColor(context)),
          ),
          subtitle: Text(
            MyDateUtil.timeAgo(Timestamp.fromDate(createdAt)),
            style: TextStyle(color: hintColor(context)),
          ),
          trailing: IconButton(
            icon: Icon(CupertinoIcons.ellipsis_vertical_circle_fill),
            color: textColor(context),
            onPressed: () {
              showCustomMenu(context, postData['postId']);
            },
          ),
        ),
        // Image Section with PageView
        Stack(
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                return Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        if (mediaUrls.isNotEmpty) {
                          final List<String> imageUrls = mediaUrls
                              .map((url) => url.toString())
                              .toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ImagePreviewPage(imageUrls: imageUrls, initialIndex: 0),
                            ),
                          );
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: mediaUrls.isNotEmpty
                            ? SizedBox(
                                height: 280,
                                width: double.infinity,
                                child: PageView.builder(
                                  itemCount: mediaUrls.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return CachedNetworkImage(
                                      imageUrl: mediaUrls[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/png_jpeg_images/kamal.JPG',
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: 280,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image,
                                    size: 50, color: Colors.grey),
                              ),
                      ),
                    ),
                    if (mediaUrls.isNotEmpty)
                      Positioned(
                        bottom: 10,
                        left: MediaQuery.of(context).size.width / 2.5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            mediaUrls.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: currentIndex == index ? 8 : 6,
                              height: currentIndex == index ? 8 : 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentIndex == index
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        // Action Buttons
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('CommanPosts')
                        .doc(postData['postId'])
                        .collection('likes')
                        .doc(Apis.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      bool liked = false;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        liked = data['liked'] ?? false;
                      }
                      return Container(
                          width: 80,
                          height: 50,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDarkMode(context)
                                ? primaryDarkBlue.withValues(alpha: 0.6)
                                : neutralLightGrey.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  liked
                                      ? CupertinoIcons.hand_thumbsup_fill
                                      : CupertinoIcons.hand_thumbsup,
                                  color: liked
                                      ? gradientEndColor
                                      : textColor(context),
                                ),
                                onPressed: () =>
                                    togglePostLike(postData['postId'], liked),
                              ),
                              FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('CommanPosts')
                                    .doc(postData['postId'])
                                    .collection('likes')
                                    .get(),
                                builder: (context, snapshot) {
                                  int likeCount = 0;
                                  if (snapshot.hasData) {
                                    likeCount = snapshot.data!.docs.length;
                                  }
                                  return Text(
                                    '$likeCount',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.orange),
                                  );
                                },
                              ),
                            ],
                          ));
                    },
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  Container(
                    width: 100,
                    height: 50,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode(context)
                          ? primaryDarkBlue.withValues(alpha: 0.6)
                          : neutralLightGrey.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(CupertinoIcons.chat_bubble_fill,
                              color: Colors.grey),
                          onPressed: () => showCommentsBottomSheet(
                              context, postData['postId']),
                        ),
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('CommanPosts')
                              .doc(postData['postId'])
                              .collection('comments')
                              .get(),
                          builder: (context, snapshot) {
                            int commentCount = 0;
                            if (snapshot.hasData) {
                              commentCount = snapshot.data!.docs.length;
                            }
                            return Text(
                              '$commentCount',
                              style: const TextStyle(color: Colors.orange),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 80,
                    height: 50,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode(context)
                          ? primaryDarkBlue.withValues(alpha: 0.6)
                          : neutralLightGrey.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child:
                        Icon(CupertinoIcons.star_circle, color: Colors.orange),
                  ),
                ],
              ),
              SizedBox(height: 5),
              if(postData['text'].isNotEmpty) Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(postData['text'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: hintColor(context),
                    )),
              ),
              FutureBuilder<Map<String, dynamic>?>(
                future: addPost.fetchMostLikedComment(postData['postId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerWidget(width: 150, height: 20);
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: TextStyle(color: textColor(context)));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return SizedBox(); // No comments available.
                  }
                  // Extract username and comment text from the fetched comment.
                  final commentData = snapshot.data!;
                  final username = commentData['username'] ?? 'Anonymous';
                  final commentText = commentData['comment'] ?? '';
                  return GestureDetector(
                    onTap: () =>
                        showCommentsBottomSheet(context, postData['postId']),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '$username : $commentText',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: hintColor(context),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
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
