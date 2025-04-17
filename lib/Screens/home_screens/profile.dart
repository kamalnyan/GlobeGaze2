import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../apis/APIs.dart';
import '../../components/LoadingAnimation.dart';
import '../../components/isDarkMode.dart';
import '../../components/profile/drawerfunctions.dart';
import '../../components/profile/editprofile.dart';
import '../../components/profile/profileGrid.dart';
import '../../components/profile/travelPostsGrid.dart';
import '../../themes/colors.dart';
import '../login_signup_screens/deleteAccount.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/favorites/favoritesGrid.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;
  const ProfilePage({super.key, this.userId});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker picker = ImagePicker();
  bool _isUploading = false;
  bool _isLoading = true;
  String? _errorMessage;

  // User data variables
  String fullName = '';
  String email = '';
  String phone = '';
  String username = '';
  String about = '';
  String imageUrl = '';
  bool isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String targetUserId = widget.userId ?? Apis.uid;
      isCurrentUser = targetUserId == Apis.uid;

      if (isCurrentUser) {
        // Load current user's data
        fullName = Apis.me.name;
        email = Apis.me.email;
        phone = Apis.me.Phone;
        username = Apis.me.username;
        about = Apis.me.about;
        imageUrl = Apis.me.image;
      } else {
        // Load other user's data
        final userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(targetUserId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          fullName = userData['FullName'] ?? '';
          email = userData['Email'] ?? '';
          phone = userData['Phone'] ?? '';
          username = userData['Username'] ?? '';
          about = userData['About'] ?? '';
          imageUrl = userData['Image'] ?? '';
        } else {
          _errorMessage = 'User not found';
        }
      }
    } catch (e) {
      _errorMessage = 'Error loading user data: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode(context) ? darkBackground : Colors.white,
        title: Text(
          username,
          style: TextStyle(color: textColor(context)),
        ),
        actions: [
          if (isCurrentUser) // Only show menu for current user
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: textColor(context),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              },
            ),
        ],
      ),
      endDrawer: isCurrentUser
          ? Drawer(
              child: Container(
                color: isDarkMode(context) ? darkBackground : Colors.white,
                padding: const EdgeInsets.only(top: 40.0),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(
                        CupertinoIcons.lock,
                        color: PrimaryColor,
                      ),
                      title: Text('Change password',
                          style: TextStyle(color: textColor(context))),
                      onTap: () {
                        handleForget(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        CupertinoIcons.trash,
                        color: Colors.red,
                      ),
                      title: Text('Delete data',
                          style: TextStyle(color: textColor(context))),
                      onTap: () {
                        Navigator.pop(context);
                        confirmAndDelete(
                            context,
                            "Delete Data",
                            "Are you sure you want to permanently delete your data?",
                            "Delete Permanently", () {
                          // UserService.deleteUserData(context, false);
                        });
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        CupertinoIcons.trash_slash_fill,
                        color: Colors.red,
                      ),
                      title: Text('Delete account',
                          style: TextStyle(color: textColor(context))),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DeleteAccount()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        CupertinoIcons.question_circle_fill,
                        color: PrimaryColor,
                      ),
                      title: Text('FAQ',
                          style: TextStyle(color: textColor(context))),
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) =>  FAQScreen()));
                      },
                    ),
                    ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.faceSmile,
                        color: PrimaryColor,
                      ),
                      title: Text('Feedback',
                          style: TextStyle(color: textColor(context))),
                      onTap: () {
                        Navigator.pop(context);
                        collectFeedbackAndSend(
                            context,
                            "Feedback Form",
                            "We value your feedback! Please share your thoughts below.",
                            "Send Feedback",
                            Apis.me.name);
                      },
                    ),
                    ListTile(
                      leading: const FaIcon(
                        FontAwesomeIcons.code,
                        color: PrimaryColor,
                      ),
                      title: Text('About us',
                          style: TextStyle(color: textColor(context))),
                      onTap: () {
                        Navigator.pop(context);
                        showAboutUsDialog(context);
                      },
                    ),
                    ListTile(
                      leading: const FaIcon(
                        CupertinoIcons.power,
                        color: Colors.red,
                      ),
                      title: Text('Log out',
                          style: TextStyle(color: textColor(context))),
                      onTap: () {
                        Navigator.pop(context);
                        handleLogout(context);
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: textColor(context)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CupertinoActivityIndicator()),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              'assets/png_jpeg_images/user.jpg'),
                                    ),
                                  ),
                                ),
                                if (isCurrentUser) // Only show edit button for current user
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final XFile? image =
                                            await picker.pickImage(
                                          source: ImageSource.gallery,
                                          imageQuality: 70,
                                        );
                                        if (image != null) {
                                          setState(() => _isUploading = true);
                                          try {
                                            String newImageUrl =
                                                await Apis.uploadProfilePicture(
                                                    File(image.path));
                                            setState(() {
                                              imageUrl = newImageUrl;
                                              Apis.me.image = newImageUrl;
                                              _isUploading = false;
                                            });
                                          } catch (e) {
                                            log('Error sending image: $e');
                                            setState(
                                                () => _isUploading = false);
                                          }
                                        } else {
                                          log('No image selected');
                                        }
                                      },
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: PrimaryColor,
                                        ),
                                        child: const Icon(
                                          CupertinoIcons.pencil,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              fullName,
                              style: TextStyle(color: textColor(context)),
                            ),
                            Text(
                              about,
                              style: TextStyle(color: hintColor(context)),
                            ),
                            if (isCurrentUser) // Only show edit profile button for current user
                              Column(
                                children: [
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      showEditProfileBottomSheet(
                                        context,
                                        fullName: fullName,
                                        email: email,
                                        username: username,
                                        about: about,
                                        phone: phone,
                                        onSaveChanges: (updatedData) {
                                          setState(() {
                                            if (updatedData
                                                .containsKey('FullName')) {
                                              fullName =
                                                  updatedData['FullName'];
                                            }
                                            if (updatedData
                                                .containsKey('Email')) {
                                              email = updatedData['Email'];
                                            }
                                            if (updatedData
                                                .containsKey('Phone')) {
                                              phone = updatedData['Phone'];
                                            }
                                            if (updatedData
                                                .containsKey('Username')) {
                                              username =
                                                  updatedData['Username'];
                                            }
                                            if (updatedData
                                                .containsKey('About')) {
                                              about = updatedData['About'];
                                            }
                                          });
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: PrimaryColor,
                                      side: BorderSide.none,
                                      shape: const StadiumBorder(),
                                    ),
                                    icon: const Text(
                                      'Edit Profile',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    label: const Icon(
                                      CupertinoIcons.right_chevron,
                                      size: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10),
                            DefaultTabController(
                              length: 3,
                              child: Column(
                                children: [
                                  TabBar(
                                    labelColor: PrimaryColor,
                                    unselectedLabelColor: hintColor(context),
                                    indicatorColor: PrimaryColor,
                                    tabs: const [
                                      Tab(text: 'Posts'),
                                      Tab(text: 'Travel Groups'),
                                      Tab(text: 'Favorites'),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 400,
                                    child: TabBarView(
                                      children: [
                                        // Common Posts Tab
                                        profileGrid(context, widget.userId ?? Apis.uid),
                                        // Travel Posts Tab
                                        travelPostsGrid(context, widget.userId ?? Apis.uid),
                                        Apis.uid != null || Apis.uid.isNotEmpty
                                            ? FavoritesGrid(context)
                                            : const Center(child: Text('Only visible to profile owner')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isUploading)
                      const Opacity(
                        opacity: 0.7,
                        child: ModalBarrier(
                            dismissible: false, color: Colors.black),
                      ),
                    if (_isUploading)
                      Center(
                        child: uploadingAnimation(),
                      ),
                  ],
                ),
    );
  }
}
