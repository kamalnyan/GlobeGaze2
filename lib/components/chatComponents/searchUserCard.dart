import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/components/chatComponents/Chatusermodel.dart';
import '../../apis/PushNotifaction.dart';
import '../../apis/APIs.dart';
import '../../themes/colors.dart';
import '../../themes/dark_light_switch.dart';
import '../mydate.dart';

class Searchusercard extends StatefulWidget {
  final ChatUser user;
  const Searchusercard({super.key, required this.user});

  @override
  State<Searchusercard> createState() => _ChatusercardState();
}

class _ChatusercardState extends State<Searchusercard> {
  bool? _isFriend; // Nullable bool to track loading state
  bool _friendRequestSent = false; // Track if the friend request is sent

  @override
  void dispose() {
    checkIfFriend();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkIfFriend(); // Call the async function in initState
  }

  Future<void> checkIfFriend() async {
    bool isFriend = await Apis.isFriend(Apis.uid, widget.user.id); // Await the Future<bool>
    setState(() {
      _isFriend = isFriend; // Set the value once check is complete
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // Navigate to messages or do something when tapped
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(
                      'assets/png_jpeg_images/user.png') as ImageProvider,
                  backgroundColor: Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode(context)
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(widget.user.about),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                // Check if _isFriend is still null (loading), or render appropriate widget
                if (_isFriend == null)
                  const CupertinoActivityIndicator() // Show loading spinner while checking friend status
                else if (_isFriend!)
                  Text(
                    MyDateUtil.getLastMessageTime(
                      context: context,
                      time: widget.user.createdAt.millisecondsSinceEpoch
                          .toString(),
                    ),
                    style: TextStyle(
                      color: isDarkMode(context) ? Timetxt : DTimetxt,
                      fontSize: 15.0,
                    ),
                  )
                else
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100), // Fast transition
                    child: _friendRequestSent
                        ? const Icon(
                      CupertinoIcons.person_crop_circle_badge_checkmark, // "Friend request sent" icon
                      color: Colors.grey,
                      key: ValueKey('requestSentIcon'),
                    )
                        : IconButton(
                      key: const ValueKey('addFriendIcon'),
                      onPressed: () {
                        Apis.addChatUser(widget.user);
                        setState(() {
                          _friendRequestSent = true;
                        });
                      },
                      icon: const Icon(
                        CupertinoIcons.person_add_solid,
                        color: PrimaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}





