import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../apis/APIs.dart';
import '../../apis/searchPostModel.dart';
import '../../components/chatComponents/Chatusermodel.dart';
import '../../components/isDarkMode.dart';
import '../../components/postComponents/gridPostShimmar.dart';
import '../../components/postComponents/new_post.dart';
import '../../components/userComponents/userDilog.dart';
import '../../themes/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<ChatUser> _allUsers = [];
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    bool isSearching = _searchQuery.isNotEmpty;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 36, 16, 16),
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode(context)
                            ? darkBackground
                            : Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(35.0),
                        ),
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
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('CommanPosts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return gridShimmar();
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading media"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No media found"));
        }
        // Convert Firestore documents into a list of Map<String, dynamic>
        final List<Map<String, dynamic>> allPosts = snapshot.data!.docs
            .map((doc) => {"id": doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 images per row
            crossAxisSpacing: 2, // horizontal space
            mainAxisSpacing: 2, // vertical space
            childAspectRatio: 1, // square cells
          ),
          itemCount: allPosts.length,
          itemBuilder: (context, index) {
            final postData = allPosts[index];
            final List<dynamic> mediaUrls = postData['mediaUrls'] ?? [];
            final String? firstImageUrl = mediaUrls.isNotEmpty ? mediaUrls[0] : null;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailPage(postData: postData),
                  ),
                );
              },
              child: Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: firstImageUrl != null
                          ? CachedNetworkImage(
                        imageUrl: firstImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 50),
                      )
                          : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Multiple Images Indicator (Top Right)
                  if (mediaUrls.length > 1)
                    Positioned(
                      top: 6,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.collections,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  /// Builds a grid of user search results.
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
        final query = _searchQuery.toLowerCase();
        final filteredUsers = _allUsers.where((user) {
          return user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query) ||
              user.username.toLowerCase().contains(query);
        }).toList();

        if (filteredUsers.isEmpty) {
          return const Center(child: Text("No matching users found"));
        }

        // Display users in a grid similar to Instagram's top results.
        return GridView.builder(
          padding: const EdgeInsets.only(top: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,      // 3 columns
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,  // slightly taller cells
          ),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return InkWell(
              onTap: () {
                showUserDialog(user, context);
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (user.image.isNotEmpty &&
                        user.image.startsWith('http'))
                        ? CachedNetworkImageProvider(user.image)
                        : const AssetImage('assets/png_jpeg_images/user.jpg')
                    as ImageProvider,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 6),
                  // Username text
                  Text(
                    user.username.length > 10
                        ? '${user.username.substring(0, 10)}...'
                        : user.username,
                    style: TextStyle(
                      fontSize: 14,
                      color: hintColor(context),
                    ),
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

class PostDetailPage extends StatelessWidget {
  final Map<String, dynamic> postData;
  const PostDetailPage({super.key, required this.postData});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: hintColor(context),
          ),
          title:  Text("Post Details",style: TextStyle(color: textColor(context)),),
          backgroundColor: isDarkMode(context)?darkBackground:Colors.white,
      ),
      body: FutureBuilder<Widget>(
        future: PostCard(context, postData),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No Post Available"));
          }
          return SingleChildScrollView(child: snapshot.data);
        },
      ),
    );
  }
}


