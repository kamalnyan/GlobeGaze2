import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/components/captilizeWords.dart';
import 'package:globegaze/components/isDarkMode.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../apis/APIs.dart';
import '../chatComponents/Chatusermodel.dart';

void showUserDialog(ChatUser user, BuildContext context) {
  // Local state variables for the dialog.
  bool friendRequestSent = false;

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      // Wrap your dialog in a StatefulBuilder to allow state updates.
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          // Local function to handle the friend request.
          Future<void> _handleFriendRequest() async {
            await Apis.addChatUser(user);
            setState(() {
              friendRequestSent = true;
            });
          }

          return AlertDialog(
            backgroundColor: isDarkMode(context)
                ? primaryDarkBlue.withOpacity(0.6)
                : neutralLightGrey.withOpacity(0.6),
            title: Center(
              child: Text(
                capitalizeWords(user.name),
                style: TextStyle(color: textColor(context)),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: (user.image.isNotEmpty && user.image.startsWith('http'))
                      ? CachedNetworkImageProvider(user.image)
                      : const AssetImage('assets/png_jpeg_images/user.jpg') as ImageProvider,
                  backgroundColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Username: ${user.username}',
                  style: TextStyle(color: hintColor(context)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Email: ${user.email}',
                  style: TextStyle(color: hintColor(context)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: hintColor(context)),
                ),
              ),
              TextButton(
                // Disable the button if the request was already sent.
                onPressed: friendRequestSent
                    ? null
                    : () async {
                  await _handleFriendRequest();
                  Navigator.of(context).pop();
                },
                child: Text(
                  friendRequestSent ? "Friend Request Sent" : "Add Friend",
                  style: const TextStyle(color: PrimaryColor),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
