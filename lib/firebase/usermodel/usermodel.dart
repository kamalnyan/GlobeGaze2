import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String fullName;
  String email;
  String about;
  String image;
  String phone;
  String username;
  bool isOnline;
  Timestamp lastActive;
  String pushToken;
  Timestamp createdAt;
  bool userAdded;

  // Constructor
  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.about,
    required this.image,
    required this.phone,
    required this.username,
    required this.isOnline,
    required this.lastActive,
    required this.pushToken,
    required this.createdAt,
    required this.userAdded,
  });

  // Factory constructor to create an instance from a JSON object (Firestore document snapshot)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['Id'] as String,
      fullName: json['FullName'] as String,
      email: json['Email'] as String,
      about: json['About'] as String,
      image: json['Image'] as String,
      phone: json['Phone'] as String,
      username: json['Username'] as String,
      isOnline: json['isOnline'] as bool,
      lastActive: json['lastActive'] as Timestamp,
      pushToken: json['pushToken'] as String,
      createdAt: json['CreatedAt'] as Timestamp,
      userAdded: json['useradded'] as bool,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'FullName': fullName,
      'Email': email,
      'About': about,
      'Image': image,
      'Phone': phone,
      'Username': username,
      'isOnline': isOnline,
      'lastActive': lastActive,
      'pushToken': pushToken,
      'CreatedAt': createdAt,
      'useradded': userAdded,
    };
  }
}
