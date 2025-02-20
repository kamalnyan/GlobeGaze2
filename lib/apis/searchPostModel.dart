import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String userId;
  final List<String> mediaUrls;

  PostModel({
    required this.postId,
    required this.userId,
    required this.mediaUrls,
  });

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: data['postId'] ?? '',
      userId: data['userId'] ?? '',
      mediaUrls: (data['mediaUrls'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}
