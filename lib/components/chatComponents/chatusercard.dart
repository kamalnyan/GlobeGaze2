import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/apis/APIs.dart';
import 'package:globegaze/components/chatComponents/Chatusermodel.dart';
import 'package:globegaze/encrypt_decrypt/endrypt.dart';

import '../../Screens/chat/messegescreen.dart';
import '../../main.dart';
import '../../themes/colors.dart';
import '../../themes/dark_light_switch.dart';
import '../mydate.dart';
import 'messegemodel.dart';

class Chatusercard extends StatefulWidget {
  final ChatUser user;
  const Chatusercard({super.key, required this.user});

  @override
  State<Chatusercard> createState() => _ChatusercardState();
}

class _ChatusercardState extends State<Chatusercard> {
  Message? _messages;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .02, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.0)),
      elevation: 0,
      color: isDarkMode(context) ? darkBackground:Colors.white,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => Messegescreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: Apis.getLastMessages(widget.user),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SizedBox()
              // CupertinoActivityIndicator()
              );
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data.'));
            }
            final data = snapshot.data?.docs;
            int _unreadCount = snapshot.data!.docs
                .where((doc) => doc['read'].isEmpty && doc['fromId'] != Apis.uid)
                .length;
            if (data != null && data.isNotEmpty && data.first.exists) {
              _messages = Message.fromJson(data.first.data());
            } else {
              _messages = null;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User image on the left
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl: widget.user.image,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(child: CupertinoActivityIndicator()),
                            errorWidget: (context, url, error) => Image.asset('assets/png_jpeg_images/user.jpg'),
                          ),
                        ),
                      ),
                      // Message, name, and time on the right
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0), // Add padding between image and text content
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode(context) ? CupertinoColors.white : CupertinoColors.black,
                                ),
                              ),
                              const SizedBox(height: 5), // Space between name and message
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: _messages != null
                                          ? (_messages!.type == Type.image
                                          ? const Row(
                                        children: [
                                          Icon(CupertinoIcons.photo_fill_on_rectangle_fill, size: 16),
                                          SizedBox(width: 5),
                                          Text("Image"),
                                        ],
                                      )
                                          : Text(
                                        EncryptionService.decryptMessage(_messages!.msg),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(color: isDarkMode(context) ? Timetxt : DTimetxt,),// Limit the message to a single line
                                      ))
                                          : Text(widget.user.about),
                                    ),
                                    const SizedBox(width: 8), // Space between the message and time
                                    _messages == null
                                        ? SizedBox.shrink() // Show nothing when no message is sent
                                        : _messages!.read.isEmpty && _messages!.fromId != Apis.uid
                                        ? // Show unread message count
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: Color.fromARGB(255, 0, 230, 119),
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                      ),
                                      child: Text("$_unreadCount", // Replace with the actual count of unread messages
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                        : // Else show the time of the last message
                                    Text(
                                      MyDateUtil.getLastMessageTime(
                                        context: context,
                                        time: _messages!.sent,
                                      ),
                                      style: TextStyle(
                                        color: isDarkMode(context) ? Timetxt : DTimetxt,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Add a Divider that starts after the picture
                  const Padding(
                    padding: EdgeInsets.only(left: 68.0), // Offset the divider to align with text content
                    child: Divider(
                      thickness: 0.5,
                      height: 20,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
