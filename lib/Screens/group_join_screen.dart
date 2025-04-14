import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../themes/colors.dart';
import 'group_details_screen.dart';

class GroupJoinScreen extends StatefulWidget {
  const GroupJoinScreen({Key? key}) : super(key: key);

  @override
  State<GroupJoinScreen> createState() => _GroupJoinScreenState();
}

class _GroupJoinScreenState extends State<GroupJoinScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _groupNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final String groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create a new group document
      final docRef = await _firestore.collection('groups').add({
        'name': groupName,
        'createdBy': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [currentUser.uid],
      });

      // Navigate to the group details screen
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupDetailsScreen(
            groupId: docRef.id,
            groupName: groupName,
            members: [currentUser.uid],
          ),
        ),
      );
      
      _groupNameController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _joinGroup(String groupId, String groupName, List<String> members) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (!members.contains(currentUser.uid)) {
        // Add the current user to the group's members list
        await _firestore.collection('groups').doc(groupId).update({
          'members': FieldValue.arrayUnion([currentUser.uid]),
        });

        // Refresh the members list
        final updatedDoc = await _firestore.collection('groups').doc(groupId).get();
        final updatedMembers = List<String>.from(updatedDoc['members']);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailsScreen(
                groupId: groupId,
                groupName: groupName,
                members: updatedMembers,
              ),
            ),
          );
        }
      } else {
        // User is already a member, just navigate to the group details
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailsScreen(
                groupId: groupId,
                groupName: groupName,
                members: members,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join group: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _groupNameController,
                          decoration: const InputDecoration(
                            hintText: 'Enter a group name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _createGroup,
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Available Groups',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('groups').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No groups available'));
                      }
                      
                      final groups = snapshot.data!.docs;
                      final currentUserId = _auth.currentUser?.uid;
                      
                      return ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final groupData = groups[index].data() as Map<String, dynamic>;
                          final groupId = groups[index].id;
                          final groupName = groupData['name'] as String;
                          final members = List<String>.from(groupData['members'] ?? []);
                          final isCurrentUserMember = members.contains(currentUserId);
                          
                          return ListTile(
                            title: Text(groupName),
                            subtitle: Text('${members.length} members'),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrentUserMember ? Colors.green : null,
                              ),
                              onPressed: () => _joinGroup(groupId, groupName, members),
                              child: Text(isCurrentUserMember ? 'Open' : 'Join'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
} 