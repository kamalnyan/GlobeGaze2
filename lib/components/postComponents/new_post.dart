import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../apis/addPost.dart';
import '../../firebase/usermodel/usermodel.dart';
import '../../themes/colors.dart';
import '../mydate.dart';
import 'comment_box.dart';

Future<Widget> PostCard(BuildContext context, Map<String, dynamic> postData) async {
  UserModel? user = await addPost.fetchUserInformation(postData['userId']);
  final List<dynamic> mediaUrls = postData['mediaUrls'] ?? [];
  int currentIndex = 0; // Local variable for tracking current page index

  // Fallback for createdAt timestamp
  final DateTime createdAt = postData['createdAt'] != null
      ? (postData['createdAt'] as Timestamp).toDate()
      : DateTime.now();

  return Padding(
    padding: const EdgeInsets.only(top: 60.0, left: 7, right: 7),
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
                : const AssetImage('assets/png_jpeg_images/user.png') as ImageProvider,
            backgroundColor: Colors.grey.shade300,
          ),
          title: Text(
            user?.fullName ?? 'Unknown User',
            style:  TextStyle(fontWeight: FontWeight.bold,color: textColor(context)),
          ),
          subtitle: Text(MyDateUtil.timeAgo(Timestamp.fromDate(createdAt)),style: TextStyle(color: hintColor(context)),),

  trailing: Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: PrimaryColor, width: 1.5),
            ),
            child:  Icon(FontAwesomeIcons.ellipsis, color: textColor(context), size: 13),
          ),
        ),

        // Image Section with PageView
        Stack(
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                return Stack(
                  children: [
                    // PageView with images
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: mediaUrls.isNotEmpty
                          ? SizedBox(
                        height: 280,
                        width: double.infinity,
                        child: PageView.builder(
                          itemCount: mediaUrls.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index; // Update outer variable
                            });
                          },
                          itemBuilder: (context, index) {
                            return CachedNetworkImage(
                              imageUrl: mediaUrls[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Image.asset(
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
                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                    // Page Indicator Dots
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
                                color: currentIndex == index ? Colors.black : Colors.grey,
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
          padding: const EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.red),
                      SizedBox(width: 20),
                      IconButton( // Wrap with IconButton
                        icon: Icon(Icons.comment, color: Colors.grey),
                        onPressed: () => showCommentsBottomSheet(context, postData['postId']),
                         // Call function
                      ),
                      SizedBox(width: 5),
                      Text('26,376', style: TextStyle(color: hintColor(context))),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.bookmark_border, color: Colors.white),
                ],
              ),
              SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('liked by ${user?.fullName ?? 'Unknown User'} and 244,389',style: TextStyle(fontWeight: FontWeight.bold,color: textColor(context))),
                  Text('kamal : waah kya baat haii',style: TextStyle(fontWeight: FontWeight.bold,color: hintColor(context))),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
