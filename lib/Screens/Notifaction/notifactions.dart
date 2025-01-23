import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:globegaze/themes/colors.dart';

import '../../apis/APIs.dart';

class Notifactions extends StatelessWidget {
  final String userId;

  Notifactions({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userId)
            .collection('Request')
            .where('userAdded', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching requests'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No Notifactions'));
          }

          List<Map<String, dynamic>> requests = snapshot.data!.docs
              .map((doc) => {
            'userRequested': doc['userRequested'],
            'userAdded': doc['userAdded'],
            'name': doc['Name'],
            'image': doc['Image'],
            'about': doc['About'],
          })
              .toList();

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(requests[index]['image']),
                    radius: 30,
                  ),
                  title: Text(requests[index]['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('About: ${requests[index]['about']}'),
                      SizedBox(height: 5),
                      Text(
                          'Added: ${requests[index]['userAdded'] ? 'Yes' : 'No'}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PrimaryColor,
                    ),
                    onPressed: () {
                      acceptFriendRequest(userId, requests[index]['userRequested'],);
                    },
                    child: Text('Accept'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  Future<void> acceptFriendRequest(String userId, String userRequested) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Request')
          .doc(userRequested)
          .update({
        'userAdded': true,
      });
      Apis.updateFriendlist(userRequested);
      print('Friend request from $userRequested accepted.');
    } catch (error) {
      print('Error accepting friend request: $error');
    }
  }
}
