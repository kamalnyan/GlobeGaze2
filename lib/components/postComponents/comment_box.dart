import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:globegaze/themes/dark_light_switch.dart';
import 'package:intl/intl.dart';

void showCommentsBottomSheet(BuildContext context, String postId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDarkMode(context) ? darkBackground : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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

    commentsCollection = FirebaseFirestore.instance.
        collection('CommanPosts').doc(widget.postId).collection('comments');
  }

  void addComment(String text) {
    if (text.isNotEmpty) {
      commentsCollection.add({
        'username': 'You',
        'profilePic': 'https://yourimageurl.com/profile.jpg', // Replace with actual URL
        'comment': text,
        'likes': 0,
        'liked': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      commentController.clear();
    }
  }

  void toggleLike(String commentId, bool liked, int likes) {
    commentsCollection.doc(commentId).update({
      'liked': !liked,
      'likes': liked ? likes - 1 : likes + 1,
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
    final likes = commentData['likes'] ?? 0;
    final liked = commentData['liked'] ?? false;
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
                : AssetImage('assets/default_avatar.png') as ImageProvider,
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
                      style: TextStyle(fontSize: 12, color: hintColor(context))),
              ],
            ),
          ),
          SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : Colors.black),
                onPressed: () => toggleLike(document.id, liked, likes),
              ),
              Text('$likes',
                  style: TextStyle(fontSize: 12, color: textColor(context))),
            ],
          ),
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
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: commentsCollection.orderBy('timestamp').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
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
                  CircleAvatar(backgroundColor: Colors.black),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Add comment...',
                        hintStyle: TextStyle(color: hintColor(context)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDarkMode(context)
                            ? primaryDarkBlue
                            : neutralLightGrey.withValues(alpha: 0.6),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  ElevatedButton.icon(
                    style:
                    ElevatedButton.styleFrom(backgroundColor: PrimaryColor),
                    onPressed: () => addComment(commentController.text),
                    icon: Icon(
                      CupertinoIcons.paperplane,
                      color: darkBackground,
                    ),
                    label: Text(
                      'Send',
                      style: TextStyle(color: darkBackground),
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
}
