import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:globegaze/components/postComponents/gridPostShimmar.dart';
import 'package:globegaze/themes/colors.dart';
import '../../apis/APIs.dart';
import '../postComponents/imagePreview.dart';



Widget profileGrid(BuildContext context, [String? userId]) {
  final String targetUserId = userId ?? Apis.uid;
  
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Users')
        .doc(targetUserId)
        .collection('Posts')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return gridShimmar();
      }
      if (snapshot.hasError) {
        return const Center(child: Text("Error loading media"));
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text("No media found"));
      }

      // Map Firestore documents into a list of posts
      final List<Map<String, dynamic>> allPosts = snapshot.data!.docs
          .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 images per row
          crossAxisSpacing: 4, // horizontal spacing
          mainAxisSpacing: 2, // vertical spacing
          childAspectRatio: 1, // square cells
        ),
        itemCount: allPosts.length,
        itemBuilder: (context, index) {
          final postData = allPosts[index];
          final List<dynamic> mediaUrls = postData['mediaUrls'] ?? [];
          final String? firstImageUrl =
          mediaUrls.isNotEmpty ? mediaUrls[0] as String : null;

          return GestureDetector(
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
            child: Stack(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: firstImageUrl != null
                        ? Hero(
                      tag: firstImageUrl,
                      child: CachedNetworkImage(
                        imageUrl: firstImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 50),
                      ),
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Show an indicator if there are multiple images.
                if (mediaUrls.length > 1)
                  Positioned(
                    top: 6,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.collections,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}
