import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:globegaze/apis/APIs.dart';
import '../../components/chatComponents/Chatusermodel.dart';
import '../../components/chatComponents/GeminiAi.dart';
import '../../components/chatComponents/chatusercard.dart';
import '../../themes/dark_light_switch.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List<ChatUser> _list = [];
  List<ChatUser> _searchList = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true; // Flag for loading state

  @override
  void initState() {
    super.initState();
    Apis.fetchUserInfo().then((value) {
      setState(() {
        _isLoading = false; // Data is fetched
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDarkMode(context)
            ? const Color(0xFF1E1E2A)
            : Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: isDarkMode(context)
              ? const Color(0xFF1E1E2A)
              : Colors.white,
          title: _isSearching
              ? CupertinoSearchTextField(
            autofocus: true,
            controller: _searchController,
            style: TextStyle(
              color: isDarkMode(context)
                  ? Colors.white
                  : Colors.black,
            ),
            onChanged: (value) {
              _searchList.clear();
              for (var i in _list) {
                if (i.name.toLowerCase().contains(value.toLowerCase()) ||
                    i.email.toLowerCase().contains(value.toLowerCase()) ||
                    i.username
                        .toLowerCase()
                        .contains(value.toLowerCase())) {
                  _searchList.add(i);
                }
              }
              setState(() {});
            },
          )
              : const Text(
            'Messages',
            style: TextStyle(
              fontSize: 29,
              fontFamily: 'MonaSans',
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching
                    ? CupertinoIcons.clear_thick
                    : CupertinoIcons.search,
              ),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _searchController.clear();
                    _searchList.clear();
                  }
                  _isSearching = !_isSearching;
                });
              },
            ),
            const SizedBox(width: 10.0),
          ],
        ),
        body: _isLoading
            ? _buildShimmerList()
            : _buildChatList(),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 10, // Shimmer skeletons count
        itemBuilder: (context, index) => _buildShimmerEffect(),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: isDarkMode(context)
          ? Colors.grey[700]!
          : Colors.grey[300]!,
      highlightColor: isDarkMode(context)
          ? Colors.grey[500]!
          : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 150,
                    height: 10,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return Column(
      children: [
        const SizedBox(
          height: 100,
          child: GeminiChatCard(),
        ),
        Expanded(
          child: StreamBuilder(
            stream: Apis.getMyUsersId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.none) {
                return _buildShimmerList(); // Show shimmer while waiting for data
              }
              if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                return StreamBuilder(
                  stream: Apis.getAllUsers(
                      snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.docs;
                    _list = data
                        ?.map((e) => ChatUser.fromJson(e.data()))
                        .toList() ??
                        [];
                    if (_list.isNotEmpty) {
                      return ListView.builder(
                        itemCount:
                        _isSearching ? _searchList.length : _list.length,
                        padding: const EdgeInsets.only(top: 10),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Chatusercard(
                            user: _isSearching
                                ? _searchList[index]
                                : _list[index],
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'No Connections Found!',
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    }
                  },
                );
              }
              return const Center(child: Text('Something went wrong!'));
            },
          ),
        ),
      ],
    );
  }
}
