import 'package:flutter/material.dart';
import 'package:globegaze/components/isDarkMode.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';

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
        backgroundColor: primaryDarkBlue,
        iconTheme: IconThemeData(
          color: isDarkMode(context)?Colors.white:Colors.black,
        ),
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
        backgroundColor: isDarkMode(context)?primaryDarkBlue:Colors.white,
        currentIndex: _currentPage,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(LineIcons.facebookMessenger, color: textColor(context)),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(LineIcons.users, color: textColor(context)),
            label: 'Group Details',
          ),
        ],
        selectedLabelStyle: TextStyle(
          color: textColor(context),
        ),
        unselectedLabelStyle: TextStyle(
          color: hintColor(context),
        ),
        selectedItemColor: textColor(context),
        unselectedItemColor: hintColor(context),
      ),
    );
  }
}