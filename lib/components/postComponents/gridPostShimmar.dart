import 'package:flutter/cupertino.dart';

import '../shimmarEffect.dart';

Widget gridShimmar() {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, // 3 images per row
      crossAxisSpacing: 2, // horizontal space
      mainAxisSpacing: 2, // vertical space
      childAspectRatio: 1, // square cells
    ),
    itemCount: 23, // Temporary shimmer items
    itemBuilder: (context, index) {
      return Stack(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: ShimmerWidget(
                  width: double.infinity, height: double.infinity),
            ),
          ),
          // Positioned(
          //   top: 6,
          //   right: 12,
          //   child: ShimmerWidget(width: 20, height: 20, borderRadius: BorderRadius.circular(20.0),),
          // ),
        ],
      );
    },
  );
}
