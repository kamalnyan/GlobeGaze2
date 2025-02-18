import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:globegaze/components/chatComponents/messegemodel.dart';
import 'package:globegaze/encrypt_decrypt/endrypt.dart';
import 'package:globegaze/themes/dark_light_switch.dart';

import '../../apis/APIs.dart';
import '../../main.dart';
import '../../themes/colors.dart';
import '../dilog.dart';
import '../mydate.dart';

class MessegeCard extends StatefulWidget {
  final Message message;
  const MessegeCard({super.key, required this.message});
  @override
  State<MessegeCard> createState() => _MessegeCardState();
}

class _MessegeCardState extends State<MessegeCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () => _showBottomSheet(isMe),
        child: isMe ? Align(
            alignment: Alignment.topRight,
            child: _Sender()) : Align(
            alignment: Alignment.topLeft,
            child: _Reciver())
    );
  }
  Widget _Reciver() {
    if (widget.message.read.isEmpty) {
      Apis.updateMessageReadStatus(widget.message);
    }
    return Container(
      padding: EdgeInsets.all(widget.message.type == Type.image
          ? mq.width * .03
          : mq.width * .04),
      margin: EdgeInsets.symmetric(
          horizontal: mq.width * .04, vertical: mq.height * .01),
      decoration: BoxDecoration(
        color: isDarkMode(context) ? primaryDarkBlue.withValues(alpha: 0.6) : neutralLightGrey.withValues(alpha: 0.6) ,
        // making borders curved
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: widget.message.type == Type.text
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EncryptionService.decryptMessage(widget.message.msg),
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode(context)
                  ? CupertinoColors.white
                  : CupertinoColors.black, // Text colors for Cupertino
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: mq.width * .04),
            child: Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode(context)
                    ? CupertinoColors.systemGrey2
                    : CupertinoColors.systemGrey, // Time text color
              ),
            ),
          ),
        ],
      )
          :
      // Show image
      ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: SizedBox(
          width: 150, // Set desired width
          height: 150, // Set desired height
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: widget.message.msg,
            placeholder: (context, url) => const Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoActivityIndicator(), // Cupertino loading indicator
            ),
            errorWidget: (context, url, error) =>
            const Icon(CupertinoIcons.photo, size: 70),
          ),
        ),
      ),
    );
  }
  Widget _Sender() {
    return Container(
      padding: EdgeInsets.all(widget.message.type == Type.image
          ? mq.width * .03
          : mq.width * .04),
      margin: EdgeInsets.symmetric(
          horizontal: mq.width * .04, vertical: mq.height * .01),
      decoration: BoxDecoration(
        color:  PrimaryColor,
        // making borders curved
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: widget.message.type == Type.text
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            EncryptionService.decryptMessage(widget.message.msg),
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode(context)
                  ? CupertinoColors.white
                  : CupertinoColors.black, // Text colors adjusted for Cupertino
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sent time
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: TextStyle(
                  fontSize: 13,
                  color: hintColor(context)
                ),
              ),
              SizedBox(width: 2),
              if (widget.message.read.isNotEmpty)
                const Icon(CupertinoIcons.check_mark_circled,
                    color: CupertinoColors.activeBlue, size: 20),
            ],
          ),
        ],
      )
          :
      // Show image
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: SizedBox(
              width: 150, // Set desired width
              height: 150, // Set desired height
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CupertinoActivityIndicator(), // Cupertino loading indicator
                ),
                errorWidget: (context, url, error) =>
                const Icon(CupertinoIcons.photo, size: 70),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sent time
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: TextStyle(
                  fontSize: 13,
                  color:  hintColor(context)
                ),
              ),
              SizedBox(width: 2),
              if (widget.message.read.isNotEmpty)
                const Icon(CupertinoIcons.checkmark_circle,
                    color: CupertinoColors.activeBlue, size: 20),
            ],
          ),
        ],
      ),
    );
  }
  void _showBottomSheet(bool isMe) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        // Title of the sheet (optional)
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),

        // List of actions
        actions: [
          // Copy text option
          CupertinoActionSheetAction(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: widget.message.msg))
                  .then((value) {
                Navigator.pop(context); // Dismiss the sheet
                Dialogs.showSnackbar(context, 'Text Copied!'); // Show a snackbar
              });
            },
            child: const Row(
              children: [
                Icon(CupertinoIcons.doc_on_doc, color: CupertinoColors.activeBlue, size: 26),
                SizedBox(width: 10),
                Text('Copy Text'),
              ],
            ),
          ),

          // Divider for 'isMe' conditions
          if (isMe) Divider(height: 1, color: CupertinoColors.systemGrey),

          // Edit message option (if it's the user's message and of type text)
          if (widget.message.type == Type.text && isMe)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context); // Dismiss the sheet
                _showMessageUpdateDialog(); // Show message update dialog
              },
              child: const Row(
                children: [
                  Icon(CupertinoIcons.pencil, color: CupertinoColors.activeBlue, size: 26),
                  SizedBox(width: 10),
                  Text('Edit Message'),
                ],
              ),
            ),

          // Delete message option (only if it's the user's message)
          if (isMe)
            CupertinoActionSheetAction(
              onPressed: () async {
                await Apis.deleteMessage(widget.message).then((value) {
                  Navigator.pop(context); // Dismiss the sheet after deletion
                });
              },
              isDestructiveAction: true,
              child: const Row(
                children: [
                  Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed, size: 26),
                  SizedBox(width: 10),
                  Text('Delete Message'),
                ],
              ),
            ),

          // Divider
          Divider(height: 1, color: CupertinoColors.systemGrey),

          // Sent time option
          CupertinoActionSheetAction(
            onPressed: () {},
            child: Row(
              children: [
                Icon(CupertinoIcons.eye_fill, color: CupertinoColors.activeBlue),
                SizedBox(width: 10),
                Text(
                    'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}'),
              ],
            ),
          ),

          // Read time option
          CupertinoActionSheetAction(
            onPressed: () {},
            child: Row(
              children: [
                Icon(CupertinoIcons.eye_fill, color: CupertinoColors.activeGreen),
                SizedBox(width: 10),
                Text(
                  widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                ),
              ],
            ),
          ),
        ],

        // Cancel button at the bottom
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context); // Dismiss the sheet
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        // Title with icon and text
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chat_bubble,
              color: CupertinoColors.activeBlue,
              size: 28,
            ),
            SizedBox(width: 10), // Add some spacing between the icon and text
            Text('Update Message'),
          ],
        ),

        // Content with input field
        content: Column(
          children: [
            SizedBox(height: 20),
            CupertinoTextField(
              controller: TextEditingController(text: updatedMsg),
              onChanged: (value) => updatedMsg = value,
              maxLines: null,
              placeholder: 'Update your message here',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: CupertinoColors.systemGrey3,
                ),
              ),
            ),
          ],
        ),

        // Actions (Cancel and Update buttons)
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              Apis.updateMessage(widget.message, updatedMsg);
            },
            isDefaultAction: true,
            child: const Text(
              'Update',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
        ],
      ),
    );
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
