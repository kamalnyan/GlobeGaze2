import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../apis/addPost.dart';
import '../../firebase/usermodel/usermodel.dart';
import '../mydate.dart';

Future<Widget> PostCard(BuildContext context, Map<String, dynamic> postData) async {
  UserModel? user = await addPost.fetchUserInformation(postData['userId']);
  final mediaUrl = postData['mediaUrls'] != null && postData['mediaUrls'].isNotEmpty
      ? postData['mediaUrls'][0]
      : '';
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 18,
                  backgroundImage: user?.image != null
                      ? CachedNetworkImageProvider(user!.image)
                      : const AssetImage('assets/png_jpeg_images/user.png') as ImageProvider,
                ),
                const SizedBox(width: 10),

                // Username & Timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'Unknown User',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        MyDateUtil.timeAgo(postData['createdAt']),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                // More Options Button
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: mediaUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: mediaUrl,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  Image.asset('assets/png_jpeg_images/kamal.JPG', fit: BoxFit.cover),
            )
                : Container(
              width: double.infinity,
              height: 280,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          ),

          // Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Row(
                  children: const [
                    Icon(Icons.favorite_border, color: Colors.black54),
                    SizedBox(width: 5),
                    Text('239', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: const [
                    Icon(Icons.comment, color: Colors.black54),
                    SizedBox(width: 5),
                    Text('8', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.bookmark_border, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
