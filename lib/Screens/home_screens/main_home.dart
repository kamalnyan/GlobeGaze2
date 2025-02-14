import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:globegaze/Screens/home_screens/profile.dart';
import 'package:globegaze/Screens/home_screens/search.dart';
import 'package:globegaze/Screens/home_screens/trips.dart';
import '../../RequestPermissions/permissions.dart';
import '../../components/profile/drawer.dart';
import '../../firebase/login_signup_methods/username.dart';
import '../../themes/colors.dart';
import '../../themes/dark_light_switch.dart';
import '../Notifaction/notifactions.dart';
import '../chat/chatList_ui.dart';
import 'add.dart';
import 'explore.dart';

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _page = 0;
  bool isDarkMode = false;
  final PageController _pageController = PageController(initialPage: 0);
  String? username;
  bool isLoading = true;
  static FirebaseAuth auth = FirebaseAuth.instance;
  static User? user = auth.currentUser;
  static String? userId = user!.uid;
  @override
  void dispose() {
    permission.requestPermissions();
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
          _page, isDarkMode, context, isLoading ? 'Loading...' : username),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _page = index;
          });
        },
        children: _pages,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.react,
        height: 70,
        backgroundColor: isDarkMode ? Colors.black38 : Colors.white,
        activeColor: PrimaryColor,
        color: isDarkMode ? Colors.white : Colors.black38,
        items: const [
          TabItem(icon: Icons.explore, title: 'Explore'),
          TabItem(icon: Icons.search, title: 'Search'),
          TabItem(icon: Icons.add, title: 'Add'),
          TabItem(icon: Icons.train, title: 'Trips'),
          TabItem(icon: Icons.account_circle, title: 'Profile'),
        ],
        initialActiveIndex: _page,
        onTap: (int index) {
          setState(() {
            _page = index;
          });
          _pageController.jumpToPage(index);
        },
      ),
    );
  }

  PreferredSizeWidget? buildAppBar(
      int pageIndex, bool isDarkMode, BuildContext context, String? username) {
    switch (pageIndex) {
      case 0:
        return AppBar(
          backgroundColor: isDarkMode?darkBackground:Colors.white,
          title: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 25,
                color: LightDark(isDarkMode),
              ),
              children: const [
                TextSpan(
                  text: 'E',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: PrimaryColor,
                    fontSize: 26,
                  ),
                ),
                TextSpan(text: 'xplore'),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.bell,color: textColor(context),),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Notifactions(userId: userId!,)));
              },
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.facebookMessenger,color: textColor(context),),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChatList()));
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
          backgroundColor: isDarkMode?darkBackground:Colors.white,
          title:  Text("My Trips",style: TextStyle(color: textColor(context)),),
          actions: [
            IconButton(
              icon:  Icon(Icons.add_circle,color: textColor(context),),
              onPressed: () {
                // Action to add a new trip
              },
            ),
          ],
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
    Trips(),
    ProfilePage(),
  ];
}
