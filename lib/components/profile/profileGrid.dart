import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../apis/addPost.dart';

Widget profileGrid(BuildContext context) {
  return FutureBuilder<List<String>>(
    future: addPost.fetchPhotos(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text("No photos available"));
      }

      final photoUrls = snapshot.data!;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // To use it within a scrollable parent
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 4 images per row
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: photoUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              photoUrls[index],
              fit: BoxFit.cover,
            ),
          );
        },
      );
    },
  );
}
