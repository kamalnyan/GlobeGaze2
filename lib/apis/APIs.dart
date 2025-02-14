
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/encrypt_decrypt/endrypt.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../Screens/login_signup_screens/login_with_email_and_passsword.dart';
import '../components/chatComponents/Chatusermodel.dart';
import '../components/chatComponents/messegemodel.dart';
import '../components/dilog.dart';
import '../firebase/login_signup_methods/AuthService.dart';
import 'PushNotifaction.dart';
final AudioPlayer _audioPlayer = AudioPlayer();
class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static String uid = auth.currentUser!.uid;
  static User? user = auth.currentUser;
  static String? userId = uid;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  static Future<void> deleteUserAccount(BuildContext context, String pass) async {
    try {
      if (user != null) {
        try {
          final credential = EmailAuthProvider.credential(
            email: user!.email!,
            password: pass,
          );
          await user!
              .reauthenticateWithCredential(credential)
              .then((result) async {
            // await deleteUserData(context, true);
            await user!.delete();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully deleted account'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            ).closed.then((_) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                    (Route<dynamic> route) => false,
              );
            });
          }).catchError((error) {
            handleAuthErrors(context, error);
          });
        } catch (e) {
          handleAuthErrors(context, e);
        }
      } else {
        throw Exception('No user is currently signed in.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  static void handleAuthErrors(BuildContext context, Object error) {
    String errorMessage;
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'wrong-password':
          errorMessage = 'The password is incorrect.';
          break;
        case 'user-mismatch':
          errorMessage = 'The provided credentials do not match the signed-in user.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found for the given email.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage = 'Authentication failed: ${error.message}';
      }
    } else {
      errorMessage = 'An unknown error occurred: $error';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
  static Future<void> changePassword(BuildContext context, String newPassword, String oldPassword) async {
    try {
      if (user== null) {
        throw Exception('No user is currently signed in.');
      }
      AuthCredential credential = EmailAuthProvider.credential(
        email: me.email,
        password: oldPassword,
      );
      await user?.reauthenticateWithCredential(credential);
      await user?.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Getting All user data for Searching
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsersindata(BuildContext context) {
    if (userId == null) {
      Dialogs.showSnackbar(context, "User not logged in ");
      throw Exception("User not logged in");
    }
    return firestore
        .collection('Users')
        .where('Id', isNotEqualTo: uid)
        .snapshots();
  }
  // Getting All Users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {
    return firestore
        .collection('Users')
        .where('Id',
        whereIn: userIds.isEmpty
            ? ['']
            : userIds)
        .snapshots();
  }
  // Getting Conversation id
  static String getConversationID(String id) => uid.hashCode <= id.hashCode ? '${uid}_$id' : '${id}_${uid}';
  // Getting All Messages of a chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }
  // Sending Text Messages
  static Future<void> sendMessage(ChatUser chatUser, String msg, Type type) async {
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
    {
      _playSound(),
      FCMService.sendPushNotification(
          chatUser.pushToken, me.name, EncryptionService.decryptMessage(msg)),
    }
    );
  }
  // Updating Mssage Read Status
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()});
  }
  // Getting Chats Last Message
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
  //Uploading profile image
  static Future<String> uploadProfilePicture( File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'profile_pictures/${uid}/profile.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    // Get the profile picture's download URL
    final profileImageUrl = await ref.getDownloadURL();
    // Update the user's profile in Firestore (or any other database)
    await firestore.collection('Users').doc(uid).update({
      'Image': profileImageUrl,
    });
    return profileImageUrl;
  }
  // Sending Images
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path
        .split('.')
        .last;
    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime
            .now()
            .millisecondsSinceEpoch}.$ext');
    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
  // Storing self information here
  static ChatUser me = ChatUser(
      id: '',
      name: '',
      email: '',
      about: '',
      image: '',
      createdAt: Timestamp.now(),
      isOnline: false,
      lastActive: Timestamp.now(),
      pushToken: '',
      username: '',
      Phone:''
  );
  // Storing Self user information
  static Future<void> fetchUserInfo() async {
    try {
      if (user == null) throw Exception("No user is currently logged in.");
      final DocumentSnapshot userDoc =
      await firestore.collection('Users').doc(user!.uid).get();
      if (userDoc.exists) {
        me = ChatUser.fromJson(userDoc.data() as Map<String, dynamic>);
        log("User info fetched successfully: ${me?.name}");
        await getFirebaseMessagingToken();
        await updateActiveStatus(true);
      } else {
        log("No user document found for UID: ${user!.uid}");
      }
    } catch (e) {
      log("Error fetching user info: $e");
    }
  }
  // Getting User Information
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser) {
    return firestore
        .collection('Users')
        .where('Id', isEqualTo: chatUser.id)
        .snapshots();
  }
  // Updating Active Status
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('Users').doc(auth.currentUser!.uid).update({
      'isOnline': isOnline,
      'lastActive': Timestamp.now(),
      'pushToken': me.pushToken
    });
  }
  //Updating User profile
  static Future<bool> updateUserProfile(Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(uid).update(updatedData);
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Fetching Push Token For PushNotiFaction
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
      }
    });
  }
  // Deleting Chat messages
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }
  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
  // Adding User to current user's database
  static Future<bool> addChatUser(ChatUser user) async {
    firestore.collection('Users')
        .doc(uid)
        .collection('Friends_List')
        .doc(user.id)
        .set({
      'friendId': user.id,
      'userAdded': false,
    }).then((_) {
      sentFriendRequest(user);
      print('Friend added successfully!');
    }).catchError((error) {
      print('Failed to add friend: $error');
    });
    return true;
  }
  //Sending Friend Request
  static Future<void> sentFriendRequest(ChatUser user) async {
    firestore.collection('Users')
        .doc(user.id)
        .collection('Request')
        .doc(uid)
        .set({
      'userRequested': uid,
      'userAdded': false,
      'Name': me.name,
      'Image': me.image,
      'About': me.about,
      'pushToken': me.pushToken,
    }).then((_) {
      FCMService.sendPushNotification(
          user.pushToken, me.name, "Sent you a friend request");
        log(user.pushToken);
      print('Friend Request Sent successfully!');
    }).catchError((error) {
      print('Failed To Sent Request: $error');
    });
  }
  // fetch All requests
  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAllRequests() {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Request')
        .snapshots();
  }
  // Checking if users are current user's  friend  or not
  static Future<bool> isFriend(String uid, String friendId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Friends_List')
          .doc(friendId)
          .get();
      return doc.exists;
    } catch (error) {
      print('Error checking user: $error');
      return false;
    }
  }
  // Getting Friend list (Friends Uids)
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Friends_List')
        .where('userAdded', isEqualTo: true)
        .snapshots();
  }
  // Updating Friend list that Current user and the user requested are friends now in both's friend list
  static Future<void> updateFriendlist(String userRequested) async {
    firestore.collection('Users')
        .doc(uid)
        .collection('Friends_List')
        .doc(userRequested)
        .set({
      'friendId': userRequested,
      'userAdded': true,
    });
    firestore
        .collection('Users')
        .doc(userRequested)
        .collection('Friends_List')
        .doc(uid)
        .update({
      'userAdded': true,   // Update the `userAdded` field to false
    }).then((_) {
      var x = FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('Request')
          .doc(userRequested)
          .snapshots();
      x.listen((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          var data = documentSnapshot.data() as Map<String, dynamic>;
          String pushToken = data['pushToken'] ?? 'No pushToken available';
          // String name = data['Name'] ?? 'No Name available';
          FCMService.sendPushNotification(pushToken, me.name, "Awesome! You've got a new friend!");
        }
      });
      print("Document successfully updated!");
    }).catchError((error) {
      print("Error updating document: $error");
    });
  }
  static Future<void> addusermsg(String message) async {
    await firestore
        .collection('Users')
        .doc(uid)
        .collection('AiMessages')
        .add({
      'text': message,
      'sender': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Add AI message to Firestore
  static Future<void> addaimsg(String message) async {
    await firestore
        .collection('Users')
        .doc(uid)
        .collection('AiMessages').add({
      'text': message,
      'sender': 'ai',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Fetch messages as a stream
  static Stream<QuerySnapshot<Map<String, dynamic>>> fetchAimessages() {
    return firestore
        .collection('Users')
        .doc(uid)
        .collection('AiMessages')
        .orderBy('timestamp', descending: true) // Order by timestamp
        .snapshots();
  }
}
// Gemini
Future<String> getGeminiResponse(String Prompt) async {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: "AIzaSyB_w6j9G2RWDaWCnoulTCg_MZtAbsCCops",
  );
  final prompt = Prompt;
  final response = await model.generateContent([Content.text(prompt)]);
  return response.text!;
}
Future<void> _playSound() async {
  await _audioPlayer.play(AssetSource('sounds/ios.wav'));
}
