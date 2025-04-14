import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:globegaze/Screens/home_screens/profile.dart';
import 'package:globegaze/Screens/home_screens/search.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import '../../RequestPermissions/permissions.dart';
import '../../themes/colors.dart';
import '../Notifaction/notifactions.dart';
import '../chat/Chats.dart';
import '../chat/chatList_ui.dart';
import '../../screens/group_join_screen.dart';
import 'add.dart';
import 'explore.dart';

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _selectedIndex = 0;
  bool isDarkMode = false;
  final PageController _pageController = PageController(initialPage: 0);
  String? username;
  bool isLoading = true;
  static FirebaseAuth auth = FirebaseAuth.instance;
  static User? user = auth.currentUser;
  static String? userId = user?.uid;

  @override
  void dispose() {
    permission.requestPermissions();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    permission.requestPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      appBar: buildAppBar(
          _selectedIndex, isDarkMode, context, isLoading ? 'Loading...' : username),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode?darkBackground:Colors.white,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: isDarkMode?primaryDarkBlue:neutralLightGrey.withValues(alpha: 0.6),
              hoverColor: isDarkMode?primaryDarkBlue:neutralLightGrey,
              gap: 8,
              activeColor: textColor(context),
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor:isDarkMode?primaryDarkBlue.withValues(alpha: 0.6):neutralLightGrey.withValues(alpha: 0.6),
              color: hintColor(context),
              tabs: const [
                GButton(
                  icon: LineIcons.globe,
                  text: 'Explore',
                ),
                GButton(
                  icon: LineIcons.search,
                  text: 'Search',
                ),
                GButton(
                  icon: LineIcons.plusCircle,
                  text: 'Add',
                ),
                GButton(
                  icon: LineIcons.user,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                _pageController.jumpToPage(index);
              },
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? buildAppBar(
      int pageIndex, bool isDarkMode, BuildContext context, String? username) {
    switch (pageIndex) {
      case 0:
        return AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'G',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.green,
                    fontFamily: 'MonaSans'),
              ),
              Text(
                'LOBE',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : textColor(context),
                    fontFamily: 'MonaSans'),
              ),
              SizedBox(width: 10),
              Text(
                'G',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.green,
                    fontFamily: 'MonaSans'),
              ),
              Text(
                'AZE',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : textColor(context),
                    fontFamily: 'MonaSans'),
              ),
            ],
          ),
          backgroundColor: isDarkMode ? darkBackground : Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(LineIcons.bell),
              color: textColor(context),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Notifactions(userId: userId!)));
              },
            ),
            const SizedBox(width: 15),
            IconButton(
              icon: Icon(FontAwesomeIcons.facebookMessenger, color: textColor(context)),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SwipeableScreens()));
              },
            ),
            const SizedBox(width: 15),
          ],
        );
      case 1:
        return null;
      case 2:
        return null;
      case 3:
        return AppBar(
          title: const Text("Groups"),
          backgroundColor: isDarkMode ? darkBackground : Colors.white,
          elevation: 0,
          centerTitle: true,
        );
      case 4:
        return null;
      default:
        return AppBar(
          title: const Text("Default"),
        );
    }
  }

  final List<Widget> _pages = [
    Explore(),
    SearchPage(),
    AddPage(),
    ProfilePage(),
  ];
}
