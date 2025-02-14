import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CommentBox(),
    );
  }
}

class CommentBox extends StatefulWidget {
  @override
  _CommentBoxState createState() => _CommentBoxState();
}


class _CommentBoxState extends State<CommentBox> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TikTok Comments UI')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showCommentsBottomSheet(context),
          child: const Text('Show Comments'),
        ),
      ),
    );
  }

  void showCommentsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CommentsSheet();
      },
    );
  }
}



class CommentsSheet extends StatefulWidget {
  @override
  _CommentsSheetState createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController commentController = TextEditingController();
  late CollectionReference commentsCollection; // Firebase collection reference

  @override
  void initState() {
    super.initState();
    commentsCollection = FirebaseFirestore.instance.collection('comments'); // Initialize collection
  }

  void addComment(String text) {
    if (text.isNotEmpty) {
      commentsCollection.add({
        'username': 'You', // Or get the actual username
        'comment': text,
        'likes': 0,
        'liked': false,
        'timestamp': FieldValue.serverTimestamp(), // Add timestamp for sorting
      });
      commentController.clear();
    }
  }

  void toggleLike(String commentId, bool liked, int likes) {
    commentsCollection.doc(commentId).update({
      'liked': !liked,
      'likes': liked ? likes -1 : likes + 1,
    });
  }

  void deleteComment(String commentId) {
    commentsCollection.doc(commentId).delete();
  }

  void _editComment(String commentId, String currentComment) {
    TextEditingController editController = TextEditingController(
      text: currentComment,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Comment'),
          content: TextField(
            controller: editController,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                commentsCollection.doc(commentId).update({
                  'comment': editController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


  void showCrudOptions(BuildContext context, DocumentSnapshot document) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Comment'),
              onTap: () {
                Navigator.pop(context);
                _editComment(document.id, document['comment']);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete Comment'),
              onTap: () {
                deleteComment(document.id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildCommentInputField() {
    return Padding(
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.black,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => addComment(commentController.text),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildComment({
    required DocumentSnapshot document,
  }) {
    final commentData = document.data() as Map<String, dynamic>;
    final username = commentData['username'] ?? '';
    final comment = commentData['comment'] ?? '';
    final likes = commentData['likes'] ?? 0;
    final liked = commentData['liked'] ?? false;
    final timestamp = commentData['timestamp'] as Timestamp?;
    final time = timestamp != null
        ? DateFormat('hh:mm a').format(timestamp.toDate()) // Format to hh:mm a
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                GestureDetector(
                  onLongPress: () => showCrudOptions(context, document),
                  child: Text(
                    comment,
                    softWrap: true,
                    overflow: TextOverflow.clip,
                  ),
                ),
                if (time != null)
                  Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(width: 8),
          IntrinsicWidth(
            child: Column(
              children: [
                IconButton(
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : Colors.black,
                  ),
                  onPressed: () => toggleLike(document.id, liked, likes),
                ),
                Text(
                  '$likes',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                stream: commentsCollection.orderBy('timestamp').snapshots(), // Order by timestamp
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator()); // Show loading indicator
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
            _buildCommentInputField(),
          ],
        ),
      ),
    );
  }
}