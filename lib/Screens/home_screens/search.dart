import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../apis/APIs.dart';
import '../../components/chatComponents/Chatusermodel.dart';
import '../../components/chatComponents/searchUserCard.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<ChatUser> _list = []; // All users
  List<ChatUser> _searchList = []; // Filtered users
  Map<String, List<String>> _friendMedia = {}; // Store media
  bool _isSearching = false; // Track search state

  @override
  void initState() {
    super.initState();
    _fetchFriendMedia(); // Fetch media when page loads
  }

  /// Fetch all media from CommanPosts
  Future<void> _fetchFriendMedia() async {
    QuerySnapshot postSnapshot =
    await FirebaseFirestore.instance.collection('CommanPosts').get();

    Map<String, List<String>> tempMedia = {};

    for (var doc in postSnapshot.docs) {
      String userId = doc['userId'];
      List<dynamic> mediaUrls = doc['mediaUrls'] ?? [];

      if (!tempMedia.containsKey(userId)) {
        tempMedia[userId] = [];
      }
      tempMedia[userId]!.addAll(mediaUrls.map((e) => e.toString()));
    }

    setState(() {
      _friendMedia = tempMedia;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0).copyWith(top: 36),
          child: Column(
            children: [
              /// Search Bar
              SizedBox(
                height: 36,
                child: CupertinoSearchTextField(
                  placeholder: 'Search users...',
                  style: const TextStyle(color: Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                      _searchList = _list.where((user) {
                        return user.name.toLowerCase().contains(value.toLowerCase()) ||
                            user.email.toLowerCase().contains(value.toLowerCase()) ||
                            user.username.toLowerCase().contains(value.toLowerCase());
                      }).toList();
                    });
                  },
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Media Grid (Always Visible)
              Expanded(
                child: _friendMedia.isEmpty
                    ? const Center(child: Text("No media found"))
                    : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 images per row
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1, // Ensures square images
                  ),
                  itemCount: _friendMedia.values.expand((list) => list).length,
                  itemBuilder: (context, index) {
                    String mediaUrl =
                    _friendMedia.values.expand((list) => list).toList()[index];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 50);
                        },
                      ),
                    );
                  },
                ),
              ),

              /// Display User List (Only When Searching)
              if (_isSearching)
                Expanded(
                  child: StreamBuilder(
                    stream: Apis.getAllUsersindata(context),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text("Error loading users"));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No users found"));
                      }

                      final data = snapshot.data!.docs;
                      _list = data.map((e) => ChatUser.fromJson(e.data())).toList();

                      return ListView.builder(
                        itemCount: _searchList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Searchusercard(user: _searchList[index]);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
