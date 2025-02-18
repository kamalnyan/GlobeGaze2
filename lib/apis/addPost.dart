import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:globegaze/apis/usermodel/usermodel.dart';
import 'package:uuid/uuid.dart';

import 'APIs.dart';


class addPost{
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> uploadPostToFirebase(
      String postText,
      List<Map<String, dynamic>> mediaFiles,
      String? location,
      {required void Function(double) onProgress}
      ) async {
    String postId = const Uuid().v4();
    List<String> mediaUrls = [];
    double totalFiles = mediaFiles.length.toDouble();
    double uploadedFiles = 0.0;

    // Upload media files to Firebase Storage
    for (var media in mediaFiles) {
      String mediaUrl;
      if (media['type'] == 'image') {
        mediaUrl = await _uploadToStorage(Uint8List.fromList(media['data']), 'PostsImg', (fileProgress) {
          onProgress((uploadedFiles + fileProgress) / totalFiles);
        });
      } else {
        continue;
      }
      mediaUrls.add(mediaUrl);
      uploadedFiles += 1.0;
      onProgress(uploadedFiles / totalFiles);
    }
    await FirebaseFirestore.instance.collection('Users').doc(Apis.uid).collection('Posts').add({
      'text': postText,
      'mediaUrls': mediaUrls,
      'location': location,
      'createdAt': Timestamp.now(),
    });
    await FirebaseFirestore.instance.collection('CommanPosts').doc(postId,).set({
      'text': postText,
      'mediaUrls': mediaUrls,
      'location': location,
      'createdAt': Timestamp.now(),
      'userId': Apis.uid,
      'postId':postId,
    });
  }

  static Stream<List<Map<String, dynamic>>> fetchCommanPosts() {
    return FirebaseFirestore.instance
        .collection('CommanPosts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList());
  }

  static Stream<List<Map<String, dynamic>>> fetchTravelPosts() {
    return FirebaseFirestore.instance
        .collection('travel_posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data(),
        }).toList());
  }

  static Future<String> _uploadToStorage(
      Uint8List fileData,
      String folderName,
      void Function(double) progressCallback,
      ) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('PostMedia')
        .child(Apis.uid)
        .child('$folderName/${DateTime.now().toIso8601String()}');
    UploadTask uploadTask = ref.putData(fileData);
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      progressCallback(progress);
    });
    await uploadTask.whenComplete(() => null);
    return await ref.getDownloadURL();
  }

  static Future<UserModel?> fetchUserInformation(String uid) async {
    try {
      DocumentSnapshot doc = await firestore.collection('Users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        print('User does not exist in the database.');
        return null;
      }
    } catch (e) {
      print('Error fetching user information: $e');
      return null;
    }
  }

  static Future<List<String>> fetchPhotos() async {
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(Apis.uid)
        .collection('Posts')
        .orderBy('createdAt', descending: true)
        .get();
    List<String> photoUrls = [];
    for (var doc in postsSnapshot.docs) {
      List<dynamic> mediaUrls = doc['mediaUrls'];
      photoUrls.addAll(mediaUrls.cast<String>());
    }
    return photoUrls;
  }
  // Place this method inside your _CommentsBottomSheetContentState class.
  static Future<Map<String, dynamic>?> fetchMostLikedComment(String postId) async {
    QuerySnapshot commentsSnapshot = await FirebaseFirestore.instance
        .collection('CommanPosts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp')
        .get();

    if (commentsSnapshot.docs.isEmpty) return null;

    int maxLikes = 0;
    Map<String, dynamic>? bestComment;
    List<Map<String, dynamic>> commentsWithLikes = [];

    // Loop through each comment to count its likes.
    for (DocumentSnapshot comment in commentsSnapshot.docs) {
      QuerySnapshot likesSnapshot = await comment.reference.collection('likes').get();
      int likesCount = likesSnapshot.docs.length;
      Map<String, dynamic> data = comment.data() as Map<String, dynamic>;
      data['likesCount'] = likesCount;
      commentsWithLikes.add(data);
      if (likesCount > maxLikes) {
        maxLikes = likesCount;
        bestComment = data;
      }
    }

    // If all comments have 0 likes, pick a random comment.
    if (maxLikes == 0 && commentsWithLikes.isNotEmpty) {
      commentsWithLikes.shuffle();
      bestComment = commentsWithLikes.first;
    }
    return bestComment;
  }
}
