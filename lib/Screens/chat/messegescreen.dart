import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/components/chatComponents/Chatusermodel.dart';
import 'package:globegaze/components/chatComponents/messege_card.dart';
import 'package:globegaze/encrypt_decrypt/endrypt.dart';
import 'package:globegaze/themes/dark_light_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../apis/APIs.dart';
import '../../components/LoadingAnimation.dart';
import '../../components/chatComponents/messegemodel.dart';
import '../../components/mydate.dart';
import '../../main.dart';
import '../../themes/colors.dart';

class Messegescreen extends StatefulWidget {
  final ChatUser user;
  const Messegescreen({super.key, required this.user});
  @override
  State<Messegescreen> createState() => _MessegescreenState();
}

class _MessegescreenState extends State<Messegescreen> {
  List<Message> _list = [];
  final _msgcontroller = TextEditingController();
  bool _showemoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          if (_showemoji) {
            setState(() {
              _showemoji = false;
            });
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          backgroundColor:
              isDarkMode(context) ? Colors.black : ChatBack, // Dark background.
          appBar: AppBar(
            backgroundColor:
                isDarkMode(context) ? Color(0xFF1E1E2A) : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back,
                  color:
                      isDarkMode(context) ? Colors.white : Color(0xFF1E1E2A)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: StreamBuilder(
                stream: Apis.getUserInfo(widget.user),
                builder: (context, snapshot) {
                  final data = snapshot.data?.docs;
                  final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                  return Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage(
                            'assets/png_jpeg_images/user.png'), // User profile image
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.isNotEmpty ? list[0].name : widget.user.name,
                            style: TextStyle(
                              color: isDarkMode(context)
                                  ? Colors.white
                                  : Color(0xFF1E1E2A),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            list.isNotEmpty
                                ? list[0].isOnline
                                    ? 'Online'
                                    : MyDateUtil.getLastActiveTime( context: context, lastActive :widget
                                .user.lastActive.millisecondsSinceEpoch.toString())
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: widget
                                        .user.lastActive.millisecondsSinceEpoch
                                        .toString()),
                            // Convert Timestamp to DateTime
                            style: TextStyle(
                              color: isDarkMode(context)
                                  ? Colors.white
                                  : Color(0xFF1E1E2A),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
            actions: [
              IconButton(
                icon: Icon(CupertinoIcons.phone,
                    color:
                        isDarkMode(context) ? Colors.white : Containerdark),
                onPressed: () {
                  // Call button action
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: Apis.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        // return
                        return const SizedBox();
                      case ConnectionState.none:
                        return const Center(
                          child: Text(
                            'No Connection Found!🥺',
                            style: TextStyle(color: PrimaryColor, fontSize: 21),
                          ),
                        );
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data!.docs;
                        _list = data
                                .map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];
                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: _list.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessegeCard(message: _list[index]);
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              "Say Hii👋",
                              style: TextStyle(fontSize: 25),
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
              if (_isUploading)
                Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: loadinganimation2())),
              _chatInput(),
              if (_showemoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: _msgcontroller,
                    config: Config(
                      height: 256,
                      emojiViewConfig: EmojiViewConfig(
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.20 : 1.0),
                      ),
                      viewOrderConfig: const ViewOrderConfig(
                        top: EmojiPickerItem.searchBar,
                        middle: EmojiPickerItem.categoryBar,
                        bottom: EmojiPickerItem.emojiView,
                      ),
                      searchViewConfig: const SearchViewConfig(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatInput() {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode(context)?DReciverBackg:Colors.white, // Adjust based on your theme
        borderRadius:  const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),

      ),
      padding: const EdgeInsets.only(bottom: 20.0, top: 20.0, left: 3),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode(context)?Textfieldlight:Textfielddark, // Adjust based on your theme
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode(context)?Textfieldlight:Textfielddark, // Adjust based on your theme
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: CupertinoTextField(
                          controller: _msgcontroller,
                          placeholder: 'Send message...',
                          cursorColor: PrimaryColor,
                          style: TextStyle(
                            color: isDarkMode(context)?Colors.white:Colors.black,           // Set your desired text color
                            decoration: TextDecoration.none, // Ensure no underline in the text
                          ),
                          decoration: null, // Removing the default underline
                          onTap: () {
                            setState(() {
                              _showemoji = false;
                            });
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Action to show attach and gallery buttons
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) => CupertinoActionSheet(
                            actions: <CupertinoActionSheetAction>[
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.camera, imageQuality: 70);
                                  if (image != null) {
                                    log('Image Path: ${image.path}');
                                    setState(() => _isUploading = true);
                                    try {
                                      await Apis.sendChatImage(
                                          widget.user, File(image.path));
                                      setState(() => _isUploading = false);
                                    } catch (e) {
                                      print('Error sending image: $e');
                                      setState(() => _isUploading = false);
                                    }
                                  }
                                },
                                child: const Row(
                                  children: [
                                    Icon(CupertinoIcons.photo_camera_solid,
                                        color: PrimaryColor),
                                    SizedBox(width: 10),
                                    Text('Camera'),
                                  ],
                                ),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final ImagePicker picker = ImagePicker();
                                  final List<XFile> images =
                                  await picker.pickMultiImage(
                                      imageQuality: 70);
                                  for (var i in images) {
                                    log('Image Path: ${i.path}');
                                    setState(() => _isUploading = true);
                                    try {
                                      await Apis.sendChatImage(
                                          widget.user, File(i.path));
                                      setState(() => _isUploading = false);
                                    } catch (e) {
                                      print('Error sending image: $e');
                                      setState(() => _isUploading = false);
                                    }
                                  }
                                },
                                child: const Row(
                                  children: [
                                    Icon(CupertinoIcons.photo_fill,
                                        color: PrimaryColor),
                                    SizedBox(width: 10),
                                    Text('Gallery'),
                                  ],
                                ),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                          ),
                        );
                      },
                      icon: Icon(CupertinoIcons.add, color: Colors.grey),
                    ),
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showemoji = !_showemoji);
                      },
                      icon: Icon(CupertinoIcons.smiley, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0,right: 8.0),
            child: CupertinoButton(
              padding: EdgeInsets.all(0), // Ensure icon size doesn't grow too much
              child: Container(
                padding: const EdgeInsets.all(12), // Padding around the icon
                decoration: const BoxDecoration(
                  color: PrimaryColor, // Custom color based on your app's theme
                  shape: BoxShape.circle, // Circular shape for the send button
                ),
                child:  const Icon(CupertinoIcons.paperplane_fill,
                    color: Colors.white, size: 24),
              ),
              onPressed: () {
                if (_msgcontroller.text.isNotEmpty) {
                  Apis.sendMessage(
                      widget.user,
                      EncryptionService.encryptMessage(_msgcontroller.text.trim()),
                      Type.text);
                  _msgcontroller.text = "";
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
