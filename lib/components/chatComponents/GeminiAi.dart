import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/firebase/usermodel/messege_model.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:globegaze/themes/dark_light_switch.dart';
import '../../Screens/chat/gemini.dart';
import '../mydate.dart';

class GeminiChatCard extends StatefulWidget {
  const GeminiChatCard({super.key});
  @override
  State<GeminiChatCard> createState() => _GeminiChatCardState();
}

class _GeminiChatCardState extends State<GeminiChatCard> {
  Message? _messages;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .02, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17.0)),
      elevation: 0,
      color: isDarkMode(context) ? const Color(0xFF1E1E2A) : Colors.white,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => const GeminiChatScreen()));
        },
        child: StreamBuilder(
          stream: null,
          // Apis.getLastMessagesForAI('gemini'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CupertinoActivityIndicator(),
              );
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data.'));
            }
                final data =['kamal','nayan'];
            // final data = snapshot.data?.docs;
            // if (data != null && data.isNotEmpty && data.first.exists) {
            //   _messages = Message.fromJson(data.first.data());
            // } else {
            //   _messages = null;
            // }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI icon/avatar
                      const CircleAvatar(
                        radius: 26,
                        backgroundImage: AssetImage('assets/png_jpeg_images/Ai.png'),
                        backgroundColor: Colors.transparent,
                      ),
                      // AI name and description
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Glory',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode(context) ? CupertinoColors.white : CupertinoColors.black,
                                ),
                              ),
                              const SizedBox(height: 5), // Space between name and message
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: _messages != null
                                          ? Text(
                                        _messages!.type == Type.image
                                            ? "Image"
                                            : _messages!.msg,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: isDarkMode(context) ? Timetxt : DTimetxt,
                                        ),
                                      )
                                          :  const Text(
                                        "Your AI Assistant",
                                        style: TextStyle(fontStyle: FontStyle.normal,color:Timetxt),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _messages == null
                                        ? const SizedBox.shrink()
                                        : Text(
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
                  const Padding(
                    padding: EdgeInsets.only(left: 68.0),
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
