import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:globegaze/components/isDarkMode.dart';
import 'package:intl/intl.dart';
import '../themes/colors.dart';
import '../services/zego_cloud_service.dart';
import '../components/chat_components/message_bubble.dart';
import '../screens/add_members_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<String> members;

  const GroupDetailsScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.members,
  }) : super(key: key);

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ZegoCloudService _zegoService = ZegoCloudService();
  late TabController _tabController;
  bool _isLoading = false;
  bool _isSending = false;
  final ScrollController _scrollController = ScrollController();
  bool _isCheckingCallStatus = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeZegoCloud();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeZegoCloud() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _zegoService.initialize();
    } catch (e) {
      print('Error initializing ZegoCloud: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to initialize video call: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade700,
            )
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final String message = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isSending = true;
    });

    try {
      await _firestore.collection('groups').doc(widget.groupId).collection('messages').add({
        'text': message,
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'Unknown User',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade700,
            )
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _startGroupCall() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to start a call')),
      );
      return;
    }

    try {
      setState(() => _isCheckingCallStatus = true);

      // Request permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      if (statuses[Permission.camera]!.isDenied || 
          statuses[Permission.microphone]!.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera and microphone permissions are required'),
            ),
          );
        }
        return;
      }

      // Create call document in Firestore
      final callDocRef = _firestore.collection('calls').doc(widget.groupId);
      final callDoc = await callDocRef.get();

      if (!callDoc.exists) {
        await callDocRef.set({
          'isActive': true,
          'startedBy': currentUser.uid,
          'startedAt': FieldValue.serverTimestamp(),
          'participants': [currentUser.uid],
          'groupId': widget.groupId,
          'groupName': widget.groupName,
        });
      } else {
        await callDocRef.update({
          'participants': FieldValue.arrayUnion([currentUser.uid]),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // Notify other members
      for (String memberId in widget.members) {
        if (memberId != currentUser.uid) {
          await _firestore.collection('notifications').add({
            'type': 'group_call',
            'groupId': widget.groupId,
            'groupName': widget.groupName,
            'callerId': currentUser.uid,
            'callerName': currentUser.displayName ?? 'Unknown User',
            'timestamp': FieldValue.serverTimestamp(),
            'userId': memberId,
            'read': false,
          });
        }
      }

      if (mounted) {
        // Join the call
        await _zegoService.joinGroupCall(
          context,
          widget.groupId,
          currentUser.uid,
          currentUser.displayName ?? 'User ${currentUser.uid.substring(0, 5)}',
          widget.groupName,
        );

        // Update call status when returning from call
        await callDocRef.update({
          'participants': FieldValue.arrayRemove([currentUser.uid]),
        });

        // If no participants left, mark call as inactive
        final updatedDoc = await callDocRef.get();
        final participants = (updatedDoc.data()?['participants'] as List?)?.length ?? 0;
        if (participants == 0) {
          await callDocRef.update({'isActive': false});
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start call: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingCallStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: textColor(context)
        ),
        backgroundColor: isDarkMode(context)?darkBackground:Colors.white,
        title: Text(
          widget.groupName,
          style:  TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor(context)
          ),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call_rounded),
            onPressed: _startGroupCall,
            tooltip: 'Start Group Call',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Group settings menu
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildGroupSettingsSheet(),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'CHAT'),
            Tab(text: 'MEMBERS'),
          ],
          labelColor: PrimaryColor,
          unselectedLabelColor: hintColor(context),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          indicatorColor: PrimaryColor,
          indicatorWeight: 3,
          dividerHeight: 0.1,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildMembersTab(),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('groups')
                .doc(widget.groupId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load messages',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                      TextButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start the conversation!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final messages = snapshot.data!.docs;
              final currentUserId = _auth.currentUser?.uid;

              return ListView.builder(
                reverse: true,
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: messages.length,
                itemBuilder: (ctx, index) {
                  final messageData = messages[index].data() as Map<String, dynamic>;
                  final isMe = messageData['senderId'] == currentUserId;
                  final timestamp = messageData['timestamp'] != null
                      ? (messageData['timestamp'] as Timestamp).toDate()
                      : DateTime.now();

                  // Group messages by date
                  bool showDateHeader = false;
                  if (index == messages.length - 1) {
                    showDateHeader = true;
                  } else {
                    final nextMessageData = messages[index + 1].data() as Map<String, dynamic>;
                    final nextTimestamp = nextMessageData['timestamp'] != null
                        ? (nextMessageData['timestamp'] as Timestamp).toDate()
                        : DateTime.now();

                    if (nextTimestamp.day != timestamp.day ||
                        nextTimestamp.month != timestamp.month ||
                        nextTimestamp.year != timestamp.year) {
                      showDateHeader = true;
                    }
                  }

                  return Column(
                    children: [
                      if (showDateHeader)
                        _buildDateHeader(timestamp),
                      MessageBubble(
                        message: messageData['text'] ?? '',
                        isMe: isMe,
                        senderName: messageData['senderName'] ?? 'Unknown User',
                        time: timestamp,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        _buildMessageComposer(),
      ],
    );
  }

  Widget _buildDateHeader(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == yesterday) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMMM d, yyyy').format(timestamp);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded,color: Colors.white,),
              onPressed: () {
                // Show attachment options
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildAttachmentSheet(),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                );
              },
              color: Theme.of(context).colorScheme.primary,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        minLines: 1,
                        maxLines: 5,
                        cursorColor: Theme.of(context).colorScheme.primary,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined,color: Colors.white,),
                      onPressed: () {
                        // Show emoji picker (would require additional package)
                      },
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            InkWell(
              onTap: _sendMessage,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PrimaryColor,
                ),
                child: _isSending
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSheet() {
    final options = [
      {'icon': Icons.image_rounded, 'label': 'Photos & Videos', 'color': Colors.blue},
      {'icon': Icons.insert_drive_file_rounded, 'label': 'Documents', 'color': Colors.orange},
      {'icon': Icons.location_on_rounded, 'label': 'Location', 'color': Colors.green},
      {'icon': Icons.contacts_rounded, 'label': 'Contacts', 'color': Colors.purple},
      {'icon': Icons.poll_rounded, 'label': 'Poll', 'color': Colors.red},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
            child: Text(
              'Share Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor(context),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16.0,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: (options[index]['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      options[index]['icon'] as IconData,
                      color: options[index]['color'] as Color,
                      size: 28.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    options[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: hintColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSettingsSheet() {
    final menuItems = [
      {'icon': Icons.notifications_outlined, 'label': 'Mute Notifications'},
      {'icon': Icons.search, 'label': 'Search in Chat'},
      {'icon': Icons.color_lens_outlined, 'label': 'Change Theme'},
      {'icon': Icons.group_add_outlined, 'label': 'Add Members'},
      {'icon': Icons.exit_to_app_rounded, 'label': 'Leave Group', 'isDanger': true},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          ...menuItems.map((item) => ListTile(
            leading: Icon(
              item['icon'] as IconData,
              color: item['isDanger'] == true
                  ? Colors.red.shade700
                  : hintColor(context),
            ),
            title: Text(
              item['label'] as String,
              style: TextStyle(
                color: item['isDanger'] == true
                    ? Colors.red.shade700
                    : hintColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              Navigator.pop(context); // Close the bottom sheet

              if (item['label'] == 'Add Members') {
                // Check if current user is the creator
                final groupDoc = await _firestore
                    .collection('groups')
                    .doc(widget.groupId)
                    .get();
                
                if (!groupDoc.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group not found')),
                  );
                  return;
                }

                final groupData = groupDoc.data()!;
                final currentUser = _auth.currentUser;
                
                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You must be logged in')),
                  );
                  return;
                }

                if (groupData['createdBy'] != currentUser.uid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Only group creator can add members'),
                    ),
                  );
                  return;
                }

                // Navigate to add members screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddMembersScreen(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      existingMembers: widget.members,
                    ),
                  ),
                );

                // Refresh members list if members were added
                if (result == true) {
                  setState(() {}); // Trigger rebuild to refresh members list
                }
              }
              // Implement other menu actions here
            },
          )),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore.collection('Users').where(FieldPath.documentId, whereIn: widget.members).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load members',
                  style: TextStyle(color: Colors.red.shade700),
                ),
                TextButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No members found'));
        }

        final currentUserId = _auth.currentUser?.uid;

        // Sort members with current user at the top
        final sortedDocs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            if (a.id == currentUserId) return -1;
            if (b.id == currentUserId) return 1;
            return 0;
          });

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: sortedDocs.length,
          itemBuilder: (context, index) {
            final userData = sortedDocs[index].data() as Map<String, dynamic>;
            final userId = sortedDocs[index].id;
            final isCurrentUser = userId == currentUserId;

            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                backgroundImage: userData['ProfilePic'] != null && userData['ProfilePic'].isNotEmpty
                    ? NetworkImage(userData['ProfilePic'])
                    : null,
                child: userData['ProfilePic'] == null || userData['ProfilePic'].isEmpty
                    ? Text(
                  userData['FullName']?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor(context),
                  ),
                )
                    : null,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      userData['FullName'] ?? 'Unknown User',
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.normal,
                          color: textColor(context)
                      ),
                    ),
                  ),
                  if (isCurrentUser)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        'You',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: textColor(context),
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                userData['Email'] ?? 'No email',
                style: TextStyle(
                  color: hintColor(context),
                  fontSize: 13.0,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              onTap: () {
                // Show member profile or actions
              },
            );
          },
        );
      },
    );
  }
}