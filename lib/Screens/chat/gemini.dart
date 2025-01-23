import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../apis/APIs.dart';
import '../../themes/colors.dart';

class GeminiChatScreen extends StatefulWidget {
  const GeminiChatScreen({Key? key}) : super(key: key);

  @override
  _GeminiChatScreenState createState() => _GeminiChatScreenState();
}

class _GeminiChatScreenState extends State<GeminiChatScreen> {
  TextEditingController _controller = TextEditingController();
  bool isTyping = false;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDarkMode ? Colors.black : ChatBack,
      appBar: AppBar(
        title: Text('Glory'),
        backgroundColor: isDarkMode ? Color(0xFF1E1E2A) : PrimaryColor,
      ),
      body: Column(
        children: [
          // StreamBuilder to listen to Firestore messages in real-time
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Apis.fetchAimessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                if(messages.isEmpty){
                  return Center(child:
                  Text("How can I assist you?",style: TextStyle(
                      color: isDarkMode?Colors.white:Colors.black,
                      fontSize: 21.0
                  ),
                  ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isTyping && index == 0) {
                      return Align(
                          alignment: Alignment.topLeft,
                          child: Lottie.asset(isDarkMode?'assets/lottie_animation/typingDark.json':
                              'assets/lottie_animation/typing.json'
                          ));
                    }
                    var messageIndex = isTyping ? index - 1 : index;
                    var message = messages[messageIndex].data() as Map<String, dynamic>;
                    return message['sender'] == 'user'
                        ? _buildUserMessage(message['text'], isDarkMode)
                        : _buildAiMessage(message['text'], isDarkMode);
                  },
                );
              },
            ),
          ),
          _buildInputField(isDarkMode),
        ],
      ),
    );
  }
  Widget _buildAiMessage(String message, bool isDarkMode) {
    List<Widget> formattedWidgets = [];

    // Split the message into lines
    List<String> lines = message.split('\n');

    for (String line in lines) {
      // Handle bullet points with bold text (e.g., * **Bold Text**)
      if (line.startsWith('*') && line.contains('**')) {
        var parts = line.split('**');
        formattedWidgets.add(
          _buildBulletPoint(
            RichText(
              text: TextSpan(
                children: parts.map((part) {
                  return TextSpan(
                    text: part,
                    style: TextStyle(
                      fontWeight: part == parts[1] ? FontWeight.bold : FontWeight.normal,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }
      // Handle bold text (e.g., **Bold Text**)
      else if (line.contains('**')) {
        var parts = line.split('**');
        formattedWidgets.add(
          RichText(
            text: TextSpan(
              children: parts.map((part) {
                return TextSpan(
                  text: part,
                  style: TextStyle(
                    fontWeight: part == parts[1] ? FontWeight.bold : FontWeight.normal,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }
      // Handle headings (## or ###)
      else if (line.startsWith("##") || line.startsWith("###")) {
        formattedWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              line.replaceFirst("##", "").replaceFirst("###", "").trim(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }
      // Handle plain bullet points
      else if (line.startsWith("•") || line.startsWith("-") || line.startsWith("*")) {
        formattedWidgets.add(_buildBulletPoint(Text(line.trim(), style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))));
      }
      // Handle plain text
      else {
        formattedWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              line.trim(),
              style: TextStyle(
                fontSize: 14.0,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        );
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF2B2B39) : Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: formattedWidgets,
        ),
      ),
    );
  }
  Widget _buildBulletPoint(Widget textWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("•", style: TextStyle(fontSize: 14.0, color: Colors.blue)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: textWidget,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildUserMessage(String message, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  Widget _buildInputField(bool isDarkMode){
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode?DReciverBackg:Colors.white, // Adjust based on your theme
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
                  color: isDarkMode?Textfieldlight:Textfielddark, // Adjust based on your theme
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: CupertinoTextField(
                          cursorColor: PrimaryColor,
                          style: TextStyle(
                            color: isDarkMode?Colors.white:Colors.black,           // Set your desired text color
                            decoration: TextDecoration.none, // Ensure no underline in the text
                          ),
                          controller: _controller,
                          placeholder: 'Ask something...',
                          decoration: null, // Removing the default underline
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0,right: 8.0),
            child: CupertinoButton(
              padding: EdgeInsets.all(0),
              onPressed:_handleSendMessage, // Ensure icon size doesn't grow too much
              child: Container(
                padding: const EdgeInsets.all(12), // Padding around the icon
                decoration: const BoxDecoration(
                  color: PrimaryColor, // Custom color based on your app's theme
                  shape: BoxShape.circle, // Circular shape for the send button
                ),
                child:  const Icon(CupertinoIcons.paperplane_fill,
                    color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _handleSendMessage() async {
    var prompt = _controller.text.trim();
    if (prompt.isNotEmpty) {
      Apis.addusermsg(prompt);
      _controller.clear();
      setState(() {
        isTyping = true;
      });
      String aiResponse = await getGeminiResponse(prompt);
      setState(() {
        isTyping = false;
      });

      Apis.addaimsg(aiResponse);
    }
  }
}
