import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    required this.username,
    required this.Phone,
  });

  late String image;
  late String about;
  late String name;
  late Timestamp createdAt;
  late bool isOnline;
  late String id;
  late Timestamp lastActive;
  late String email;
  late String pushToken;
  late String username;
  late String Phone;
  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['Image'] ?? '';
    about = json['About'] ?? '';
    name = json['FullName'] ?? '';
    Phone = json['Phone'] ?? '';
    createdAt = json['CreatedAt'] != null && json['CreatedAt'] is Timestamp
        ? json['CreatedAt'] as Timestamp
        : Timestamp.now();
    isOnline = json['isOnline'] ?? false;
    id = json['Id'] ?? '';
    lastActive = json['lastActive'] != null && json['lastActive'] is Timestamp
        ? json['lastActive'] as Timestamp
        : Timestamp.now();
    email = json['Email'] ?? '';
    pushToken = json['pushToken'] ?? '';
    username = json['Username'] ?? '';
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['Image'] = image;
    data['About'] = about;
    data['FullName'] = name;
    data['CreatedAt'] = createdAt;
    data['isOnline'] = isOnline;
    data['Id'] = id;
    data['lastActive'] = lastActive;
    data['Email'] = email;
    data['pushToken'] = pushToken;
    data['Username'] = username;
    return data;
  }
}
