import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/isDarkMode.dart';
import '../themes/colors.dart';

class AddMembersScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<String> existingMembers;

  const AddMembersScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.existingMembers,
  }) : super(key: key);

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  List<String> _selectedUsers = [];
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addMembers() async {
    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select users to add')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get the current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Check if current user is group creator
      final groupDoc = await _firestore.collection('groups').doc(widget.groupId).get();
      final groupData = groupDoc.data();
      if (groupData == null) throw Exception('Group not found');
      
      if (groupData['createdBy'] != currentUser.uid) {
        throw Exception('Only group creator can add members');
      }

      // Update group members
      await _firestore.collection('groups').doc(widget.groupId).update({
        'members': FieldValue.arrayUnion(_selectedUsers),
      });

      // Send notifications to added members
      for (String userId in _selectedUsers) {
        await _firestore.collection('notifications').add({
          'userId': userId,
          'type': 'group_invite',
          'groupId': widget.groupId,
          'groupName': widget.groupName,
          'senderId': currentUser.uid,
          'senderName': currentUser.displayName ?? 'Unknown User',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Members added successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode(context) ? darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode(context) ? darkBackground : Colors.white,
        title: Text(
          'Add Members',
          style: TextStyle(
            color: textColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: textColor(context)),
        elevation: 0,
        actions: [
          if (_selectedUsers.isNotEmpty)
            TextButton(
              onPressed: _isLoading ? null : _addMembers,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(PrimaryColor),
                      ),
                    )
                  : Text(
                      'Add (${_selectedUsers.length})',
                      style: const TextStyle(
                        color: PrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(color: hintColor(context)),
                prefixIcon: Icon(Icons.search, color: hintColor(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: hintColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: hintColor(context)),
                ),
                filled: true,
                fillColor: isDarkMode(context)
                    ? Colors.grey[800]
                    : Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Users')
                  .where('Id', isNotEqualTo: _auth.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                final users = snapshot.data!.docs
                    .where((doc) {
                      final userData = doc.data() as Map<String, dynamic>;
                      final fullName = (userData['FullName'] ?? '').toString().toLowerCase();
                      final email = (userData['Email'] ?? '').toString().toLowerCase();
                      final searchLower = _searchQuery.toLowerCase();
                      
                      // Filter out existing members and match search query
                      return !widget.existingMembers.contains(doc.id) &&
                          (fullName.contains(searchLower) ||
                              email.contains(searchLower));
                    })
                    .toList();

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No users available to add'
                          : 'No users found matching "$_searchQuery"',
                      style: TextStyle(color: hintColor(context)),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData = users[index].data() as Map<String, dynamic>;
                    final userId = users[index].id;
                    final isSelected = _selectedUsers.contains(userId);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: PrimaryColor.withOpacity(0.2),
                        backgroundImage: userData['ProfilePic'] != null &&
                                userData['ProfilePic'].toString().isNotEmpty
                            ? NetworkImage(userData['ProfilePic'])
                            : null,
                        child: userData['ProfilePic'] == null ||
                                userData['ProfilePic'].toString().isEmpty
                            ? Text(
                                (userData['FullName'] ?? 'U')[0].toUpperCase(),
                                style: TextStyle(
                                  color: textColor(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        userData['FullName'] ?? 'Unknown User',
                        style: TextStyle(
                          color: textColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        userData['Email'] ?? '',
                        style: TextStyle(color: hintColor(context)),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: isSelected ? PrimaryColor : hintColor(context),
                        ),
                        onPressed: () {
                          setState(() {
                            if (isSelected) {
                              _selectedUsers.remove(userId);
                            } else {
                              _selectedUsers.add(userId);
                            }
                          });
                        },
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