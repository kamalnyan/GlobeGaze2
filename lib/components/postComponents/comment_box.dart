import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:globegaze/themes/dark_light_switch.dart';
import 'package:intl/intl.dart';

import '../../apis/APIs.dart';
import '../shimmarEffect.dart';

void showCommentsBottomSheet(BuildContext context, String postId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDarkMode(context) ? darkBackground : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(46)),
    ),
    builder: (context) {
      return _CommentsBottomSheetContent(postId: postId);
    },
  );
}

class _CommentsBottomSheetContent extends StatefulWidget {
  final String postId;

  const _CommentsBottomSheetContent({Key? key, required this.postId})
      : super(key: key);

  @override
  _CommentsBottomSheetContentState createState() =>
      _CommentsBottomSheetContentState();
}

class _CommentsBottomSheetContentState
    extends State<_CommentsBottomSheetContent> {
  final TextEditingController commentController = TextEditingController();
  late CollectionReference commentsCollection;

  @override
  void initState() {
    super.initState();
    commentsCollection = FirebaseFirestore.instance
        .collection('CommanPosts')
        .doc(widget.postId)
        .collection('comments');
  }

  Future<void> addComment(String text) async {
    if (text.isNotEmpty) {
      // Create the comment document and await its reference.
      DocumentReference commentRef = await commentsCollection.add({
        'username': Apis.me.username,
        'profilePic': Apis.me.image.isEmpty ? '' : Apis.me.image,
        'comment': text,
        'postId': widget.postId,
        'uid': Apis.me.id,
        'timestamp': FieldValue.serverTimestamp(),
      });
      commentController.clear();
    }
  }

  void toggleLike(String commentId, bool liked) {
    DocumentReference likeDoc = commentsCollection
        .doc(commentId)
        .collection('likes')
        .doc(Apis.uid);

    likeDoc.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        likeDoc.update({
          'liked': !liked,
          'userId': Apis.uid,
        });
      } else {
        likeDoc.set({
          'liked': true,
          'userId': Apis.uid,
        });
      }
    });
  }

  void deleteComment(String commentId) {
    commentsCollection.doc(commentId).delete();
  }

  Widget _buildComment({required DocumentSnapshot document}) {
    final commentData = document.data() as Map<String, dynamic>;
    final username = commentData['username'] ?? '';
    final comment = commentData['comment'] ?? '';
    final profilePicUrl = commentData['profilePic'] ?? '';
    final timestamp = commentData['timestamp'] as Timestamp?;
    final time = timestamp != null
        ? DateFormat('hh:mm a').format(timestamp.toDate())
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: profilePicUrl.isNotEmpty
                ? NetworkImage(profilePicUrl)
                : AssetImage('assets/png_jpeg_images/user.jpg') as ImageProvider,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor(context))),
                Text(
                  comment,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  style: TextStyle(color: hintColor(context)),
                ),
                if (time != null)
                  Text(time,
                      style:
                      TextStyle(fontSize: 12, color: hintColor(context))),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('CommanPosts')
                    .doc(widget.postId)
                    .collection('comments')
                    .doc(document.id)
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
                  return IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      color: liked ? Colors.red : textColor(context),
                    ),
                    onPressed: () => toggleLike(document.id, liked),
                  );
                },
              ),
              // FutureBuilder to fetch the total likes count for this comment.
              FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('CommanPosts')
                    .doc(widget.postId)
                    .collection('comments')
                    .doc(document.id)
                    .collection('likes')
                    .get(),
                builder: (context, snapshot) {
                  int likesCount = 0;
                  if (snapshot.hasData) {
                    likesCount = snapshot.data!.docs.length;
                  }
                  return Text(
                    '$likesCount',
                    style: TextStyle(fontSize: 12, color: textColor(context)),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 40,
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: hintColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: commentsCollection
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return _shimmarEffect();
                  }
                  final comments = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final document = comments[index];
                      return _buildComment(document: document);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10, top: 5),
              child: Row(
                children: [
                  CircleAvatar(
                      backgroundImage: AssetImage(Apis.me.image),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      style: TextStyle(color: textColor(context)),
                      decoration: InputDecoration(
                        hintText: 'Add comment...',
                        hintStyle: TextStyle(color: hintColor(context)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDarkMode(context)
                            ? primaryDarkBlue.withValues(alpha: 0.6)
                            : neutralLightGrey.withValues(alpha: 0.6),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      cursorColor: PrimaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: PrimaryColor),
                    onPressed: () => addComment(commentController.text),
                    icon: Icon(
                      CupertinoIcons.paperplane,
                      color: gradientStartColor,
                    ),
                    label: Text(
                      'Send',
                      style: TextStyle(color: gradientStartColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerWidget(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))), // Profile Picture Placeholder
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerWidget(width: 100, height: 12, borderRadius: BorderRadius.all(Radius.circular(4))), // Username Placeholder
                const SizedBox(height: 4),
                const ShimmerWidget(width: double.infinity, height: 14, borderRadius: BorderRadius.all(Radius.circular(4))), // Comment Line 1
                const SizedBox(height: 4),
                const ShimmerWidget(width: 200, height: 14, borderRadius: BorderRadius.all(Radius.circular(4))), // Comment Line 2
                const SizedBox(height: 6),
                const ShimmerWidget(width: 50, height: 10, borderRadius: BorderRadius.all(Radius.circular(4))), // Timestamp Placeholder
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              const ShimmerWidget(width: 20, height: 20, borderRadius: BorderRadius.all(Radius.circular(4))), // Like Icon Placeholder
              const SizedBox(height: 4),
              const ShimmerWidget(width: 20, height: 12, borderRadius: BorderRadius.all(Radius.circular(4))), // Like Count Placeholder
            ],
          )
        ],
      ),
    );
  }
  Widget _shimmarEffect(){
    return Column(
    children: [
      _buildCommentShimmer(),
      const SizedBox(height: 10,),
      _buildCommentShimmer(),
      const SizedBox(height: 10,),
      _buildCommentShimmer(),
      const SizedBox(height: 10,),
      _buildCommentShimmer(),
      const SizedBox(height: 10,),
    ],
    );
  }
}
