import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../apis/APIs.dart';
import '../../components/chatComponents/Chatusermodel.dart';
import '../../components/chatComponents/searchUserCard.dart';
import '../../themes/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<ChatUser> _list = [];
  List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0).copyWith(top: 36),
        child: Column(
          children: [
            SizedBox(
              height: 36,
              child: CupertinoSearchTextField(
                placeholder: 'Search',
                style: const TextStyle(color: Colors.white),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                onChanged: (value) {
                  if (value.isEmpty) {
                    _searchList.clear();
                  } else {
                    // Search for matching users
                    _searchList = _list.where((user) {
                      return user.name.toLowerCase().contains(value.toLowerCase()) ||
                          user.email.toLowerCase().contains(value.toLowerCase()) ||
                          user.username.toLowerCase().contains(value.toLowerCase());
                    }).toList();
                  }
                  setState(() {});
                },
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: Apis.getAllUsersindata(context),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Stack(
                        children: [
                          const Opacity(
                            opacity: 0.7,
                            child: ModalBarrier(dismissible: false, color: Colors.black),
                          ),
                          Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              size: 67,
                              color: PrimaryColor,
                            ),
                          ),
                        ],
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data!.docs;
                      _list = data.map((e) => ChatUser.fromJson(e.data())).toList();

                      if (_searchList.isNotEmpty) {
                        return ListView.builder(
                          itemCount: _searchList.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Searchusercard(user: _searchList[index]);
                          },
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "No posts available",
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }
                    default:
                      return const Center(
                        child: Text('Something went wrong'),
                      );
                  }
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
