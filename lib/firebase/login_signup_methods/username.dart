import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<void> addUsernameToUserDocument(String uid, String username) async {
  try {
    var usernameQuery = await _firestore
        .collection('Users')
        .where('Username', isEqualTo: username)
        .get();
    if (usernameQuery.docs.isEmpty) {
      await _firestore.collection('Users').doc(uid).update({
        'Username': username,
      });
      print('Username added successfully.');
    } else {
      print('Username already exists. Please choose another one.');
    }
  } catch (e) {
    print('Error adding username: $e');
  }
}
Future<String?> getUsernameFromFirestore(String uid) async {
  try {
    DocumentSnapshot userDoc = await _firestore.collection('Users').doc(uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      var data = userDoc.data() as Map<String, dynamic>;
      if (data.containsKey('Username')) {
        return data['Username'];
      } else {
        print('Username field does not exist in the document.');
        return null;
      }
    } else {
      print('User document does not exist.');
      return null;
    }
  } catch (e) {
    print('Error fetching username: $e');
    return null;
  }
}
String trimBeforeAt(String email) {
  if (email.contains('@')) {
    return email.split('@')[0];
  }
  return email; // Return original if '@' is not found
}