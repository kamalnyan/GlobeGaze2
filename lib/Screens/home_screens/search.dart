import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../apis/APIs.dart';
import '../../components/chatComponents/Chatusermodel.dart';
import '../../components/isDarkMode.dart';
import '../../components/userComponents/userDilog.dart';
import '../../themes/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // All users from stream
  List<ChatUser> _allUsers = [];
  // Current search query text
  String _searchQuery = "";

  // Store media from CommanPosts
  Map<String, List<String>> _friendMedia = {};

  @override
  void initState() {
    super.initState();
    _fetchFriendMedia();
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
    // Determine if we are searching based on the query text.
    bool isSearching = _searchQuery.isNotEmpty;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
          child: Column(
            children: [
              SizedBox(height: 20.0,),
              Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode(context)
                                ? darkBackground
                                : Colors.white,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(35.0)),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode(context)
                                    ? primaryDarkBlue
                                    : Colors.grey,
                                blurRadius: 5.0,
                                spreadRadius: 4.0,
                              )
                            ],
                          ),
                          child: TextField(
                              style: TextStyle(color: textColor(context)),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                  color: textColor(context),
                                ),
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: textColor(context),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              }),
                        ),
                      ),
                    ],
                  ),
              Expanded(
                child: isSearching ? _buildSearchResults() : _buildMediaGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    // Flatten the media URLs into a single list.
    List<String> allMedia = _friendMedia.values.expand((list) => list).toList();

    if (allMedia.isEmpty) {
      return const Center(child: Text("No media found"));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 images per row
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1, // Square images
      ),
      itemCount: allMedia.length,
      itemBuilder: (context, index) {
        String mediaUrl = allMedia[index];
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
    );
  }
  /// Build grid view for search results (users)
  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
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

        // Map snapshot data into ChatUser models.
        _allUsers = snapshot.data!.docs
            .map((e) => ChatUser.fromJson(e.data() as Map<String, dynamic>))
            .toList();

        // Filter users based on the search query.
        List<ChatUser> filteredUsers = _allUsers.where((user) {
          String query = _searchQuery.toLowerCase();
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.username.toLowerCase().contains(query);
        }).toList();

        if (filteredUsers.isEmpty) {
          return const Center(child: Text("No matching users found"));
        }

        // Display users in a grid similar to Instagram's top results.
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Adjust as desired
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8, // Slightly taller than wide
          ),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            ChatUser user = filteredUsers[index];
            return InkWell(
              onTap: (){
                showUserDialog(user,context);
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (user != null &&
                        user.image.isNotEmpty &&
                        user.image.startsWith('http'))
                        ? CachedNetworkImageProvider(user.image)
                        : const AssetImage('assets/png_jpeg_images/user.jpg') as ImageProvider,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 6),
                  // Username text.
                  Text(
                    user.username.length > 10
                        ? '${user.username.substring(0, 10)}...'
                        : user.username,
                    style: TextStyle(fontSize: 14, color: hintColor(context)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
