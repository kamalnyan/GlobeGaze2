import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../themes/colors.dart';
import '../services/zego_cloud_service.dart';
import '../components/chat_components/message_bubble.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize video call: $e'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final String message = _messageController.text.trim();
    _messageController.clear();

    try {
      await _firestore.collection('groups').doc(widget.groupId).collection('messages').add({
        'text': message,
        'senderId': currentUser.uid,
        'senderName': currentUser.displayName ?? 'Unknown User',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e'))
      );
    }
  }

  void _startGroupCall() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    _zegoService.joinGroupCall(
      context, 
      widget.groupId, 
      currentUser.uid, 
      currentUser.displayName ?? 'User ${currentUser.uid.substring(0, 5)}'
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeColors = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: isDarkMode ? darkBackground : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: _startGroupCall,
            tooltip: 'Start Group Call',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chat'),
            Tab(text: 'Members'),
          ],
          labelColor: textColor(context),
          indicatorColor: themeColors.primary,
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No messages yet!'));
              }
              
              final messages = snapshot.data!.docs;
              final currentUserId = _auth.currentUser?.uid;
              
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(10.0),
                itemCount: messages.length,
                itemBuilder: (ctx, index) {
                  final messageData = messages[index].data() as Map<String, dynamic>;
                  final isMe = messageData['senderId'] == currentUserId;
                  
                  return MessageBubble(
                    message: messageData['text'] ?? '',
                    isMe: isMe,
                    senderName: messageData['senderName'] ?? 'Unknown User',
                    time: messageData['timestamp'] != null 
                        ? (messageData['timestamp'] as Timestamp).toDate() 
                        : DateTime.now(),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -1),
                blurRadius: 5,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: hintColor(context).withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                  minLines: 1,
                  maxLines: 5,
                ),
              ),
              const SizedBox(width: 8.0),
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab() {
    return FutureBuilder<QuerySnapshot>(
      future: _firestore.collection('Users').where(FieldPath.documentId, whereIn: widget.members).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No members found'));
        }
        
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final userId = snapshot.data!.docs[index].id;
            
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: userData['ProfilePic'] != null && userData['ProfilePic'].isNotEmpty
                    ? NetworkImage(userData['ProfilePic'])
                    : null,
                child: userData['ProfilePic'] == null || userData['ProfilePic'].isEmpty
                    ? Text(userData['FullName']?.substring(0, 1) ?? 'U')
                    : null,
              ),
              title: Text(userData['FullName'] ?? 'Unknown User'),
              subtitle: Text(userData['Email'] ?? 'No email'),
              trailing: userId == _auth.currentUser?.uid
                  ? const Chip(label: Text('You'))
                  : null,
            );
          },
        );
      },
    );
  }
} 