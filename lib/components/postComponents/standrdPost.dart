// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:provider/provider.dart';
//
// import '../../Providers/postProviders/imageMediaProviders.dart';
//
// // Overlay widget for showing extra media count
// Widget buildOverlay(int extraCount) {
//   return ClipRRect(
//     borderRadius: BorderRadius.circular(10.0),
//     child: Container(
//       color: Colors.black54,
//       child: Center(
//         child: Text(
//           '+$extraCount',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     ),
//   );
// }
//
// // Main widget for creating a standard post layout
// Widget buildStandardPost(
//     BuildContext context,
//     TextEditingController postController,
//     Function pickMedia,
//     Function pickLocation,
//     List<Map<String, dynamic>> savedDrafts,
//     Function(Map<String, dynamic>) deleteDraft,
//     void Function() showDraftListDialog,
//     ) {
//   final mediaProvider = Provider.of<MediaProvider>(context);
//
//   // Calculate media count and display count
//   int mediaCount = mediaProvider.selectedMedia.isNotEmpty
//       ? mediaProvider.selectedMedia.length
//       : mediaProvider.newSelectedMedia.length;
//   int displayCount = mediaCount > 4 ? 4 : mediaCount;
//
//   // Function to retrieve active media list from the provider
//   List<dynamic> getActiveMedia() {
//     if (mediaProvider.selectedMedia.isNotEmpty) {
//       return mediaProvider.selectedMedia;
//     } else if (mediaProvider.newSelectedMedia.isNotEmpty) {
//       return mediaProvider.newSelectedMedia;
//     }
//     return [];
//   }
//
//   // Widget for displaying media thumbnail from Uint8List
//   Widget buildMediaThumbnail(Uint8List data, int index) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10.0),
//           child: Image.memory(data, fit: BoxFit.cover),
//         ),
//         if (index == 3 && mediaCount > 4) buildOverlay(mediaCount - 4),
//       ],
//     );
//   }
//
//   // Widget for displaying media thumbnail from File
//   Widget buildFileThumbnail(File file, int index) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(10.0),
//           child: Image.file(file, fit: BoxFit.cover),
//         ),
//         if (index == 3 && mediaCount > 4) buildOverlay(mediaCount - 4),
//       ],
//     );
//   }
//
//   // Widget for media grid display
//   Widget buildMediaGrid() {
//     final activeMedia = getActiveMedia();
//     return activeMedia.isNotEmpty
//         ? Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 4,
//           mainAxisSpacing: 4,
//         ),
//         itemCount: displayCount,
//         itemBuilder: (context, index) {
//           if (activeMedia[index] is AssetEntity) {
//             return FutureBuilder<Uint8List?>(
//               future: (activeMedia[index] as AssetEntity).thumbnailData,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done &&
//                     snapshot.hasData) {
//                   return buildMediaThumbnail(snapshot.data!, index);
//                 }
//                 return const CupertinoActivityIndicator(radius: 15.0);
//               },
//             );
//           } else if (activeMedia[index] is File) {
//             return buildFileThumbnail(activeMedia[index] as File, index);
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     )
//         : const SizedBox.shrink();
//   }
//
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: TextField(
//           controller: postController,
//           maxLines: null,
//           keyboardType: TextInputType.multiline,
//           decoration: const InputDecoration(
//             hintText: "How was your experience?",
//             border: InputBorder.none,
//           ),
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             IconButton(
//               onPressed: () => pickMedia(),
//               icon: const Column(
//                 children: [
//                   Icon(CupertinoIcons.photo),
//                   SizedBox(height: 5),
//                   Text('Gallery'),
//                 ],
//               ),
//             ),
//             IconButton(
//               onPressed: () => pickLocation(),
//               icon: const Column(
//                 children: [
//                   Icon(CupertinoIcons.location),
//                   SizedBox(height: 5),
//                   Text('Location'),
//                 ],
//               ),
//             ),
//             IconButton(
//               onPressed: () => showDraftListDialog(),
//               icon: const Column(
//                 children: [
//                   Icon(CupertinoIcons.collections),
//                   SizedBox(height: 5),
//                   Text('Saved drafts'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       buildMediaGrid(),
//     ],
//   );
// }
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../Providers/postProviders/imageMediaProviders.dart';
import '../../Screens/home_screens/explore.dart';
import 'locationBottomSheet.dart';

Widget buildStandardPost(
    BuildContext context,
    TextEditingController postController,
    Function pickMedia,
    Function showDraftListDialog,
    ) {
  final mediaProvider = Provider.of<MediaProvider>(context);
  int mediaCount = mediaProvider.selectedMedia.isNotEmpty
      ? mediaProvider.selectedMedia.length
      : mediaProvider.newSelectedMedia.length;
  int displayCount = mediaCount > 4 ? 4 : mediaCount;

  List<dynamic> getActiveMedia() {
    if (mediaProvider.selectedMedia.isNotEmpty) {
      return mediaProvider.selectedMedia;
    } else if (mediaProvider.newSelectedMedia.isNotEmpty) {
      return mediaProvider.newSelectedMedia;
    }
    return [];
  }

  Widget buildMediaThumbnail(Uint8List data, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.memory(data, fit: BoxFit.cover),
        ),
        if (index == 3 && mediaCount > 4) buildOverlay(mediaCount - 4),
      ],
    );
  }

  Widget buildFileThumbnail(File file, int index) {
    if (!file.existsSync()) {
      return const SizedBox.shrink();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.file(file, fit: BoxFit.cover),
        ),
        if (index == 3 && mediaCount > 4) buildOverlay(mediaCount - 4),
      ],
    );
  }

  Widget buildMediaGrid() {
    final activeMedia = getActiveMedia();
    return activeMedia.isNotEmpty
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: displayCount,
        itemBuilder: (context, index) {
          if (activeMedia[index] is AssetEntity) {
            return FutureBuilder<Uint8List?>(
              future: (activeMedia[index] as AssetEntity).thumbnailData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return buildMediaThumbnail(snapshot.data!, index);
                }
                return const CupertinoActivityIndicator(radius: 15.0);
              },
            );
          } else if (activeMedia[index] is File) {
            return buildFileThumbnail(activeMedia[index] as File, index);
          }
          return const SizedBox.shrink();
        },
      ),
    )
        : const SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: postController,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: "How was your experience?",
            border: InputBorder.none,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => pickMedia(),
              icon: const Column(
                children: [
                  Icon(CupertinoIcons.photo),
                  SizedBox(height: 5),
                  Text('Gallery'),
                ],
              ),
            ),
            IconButton(
              onPressed: () => showLocationBottomSheet(context),
              icon: const Column(
                children: [
                  Icon(CupertinoIcons.location),
                  SizedBox(height: 5),
                  Text('Location'),
                ],
              ),
            ),
            IconButton(
              onPressed: () => showDraftListDialog(),
              icon: const Column(
                children: [
                  Icon(CupertinoIcons.collections),
                  SizedBox(height: 5),
                  Text('Saved drafts'),
                ],
              ),
            ),
          ],
        ),
      ),
      buildMediaGrid(),
    ],
  );
}
Widget buildOverlay(int extraCount) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10.0),
    child: Container(
      color: Colors.black54,
      child: Center(
        child: Text(
          '+$extraCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
void _showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Post Successful'),
      content: const Text('Your post has been uploaded successfully!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Explore())),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
