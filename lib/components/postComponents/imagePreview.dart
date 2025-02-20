import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../themes/colors.dart';

class ImagePreviewPage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImagePreviewPage({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: textColor(context)
        ),
        backgroundColor: Colors.black,
        title: Text('${initialIndex + 1} / ${imageUrls.length}',style: TextStyle(color: textColor(context)),),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Center(
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.contain,
              placeholder: (context, url) =>
              const CircularProgressIndicator(color: Colors.white),
              errorWidget: (context, url, error) =>
              const Icon(Icons.error, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}