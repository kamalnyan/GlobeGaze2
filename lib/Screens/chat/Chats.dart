import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';

import '../../screens/group_join_screen.dart';
import 'chatList_ui.dart';

class SwipeableScreens extends StatefulWidget {
  const SwipeableScreens({Key? key}) : super(key: key);

  @override
  State<SwipeableScreens> createState() => _SwipeableScreensState();
}

class _SwipeableScreensState extends State<SwipeableScreens> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPage == 0 ? 'Messages' : 'Groups',
          style: TextStyle(
            fontSize: 29,
            fontFamily: 'MonaSans',
            fontWeight: FontWeight.bold,
            color: textColor(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              _pageController.animateToPage(
                _currentPage == 0 ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          ChatList(),
          GroupJoinScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Group Details',
          ),
        ],
      ),
    );
  }
}