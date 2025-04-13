import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../themes/colors.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String senderName;
  final DateTime time;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.senderName,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final messageColor = isMe 
        ? (isDarkMode ? Colors.blue[700] : Colors.blue[500])
        : (isDarkMode ? Colors.grey[800] : Colors.grey[200]);
    
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: messageColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
            ),
          ),
          width: MediaQuery.of(context).size.width * 0.7,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) 
                Text(
                  senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              if (!isMe) const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  color: isMe 
                      ? Colors.white 
                      : (isDarkMode ? Colors.white : Colors.black87),
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    DateFormat.jm().format(time),
                    style: TextStyle(
                      fontSize: 12,
                      color: isMe 
                          ? Colors.white70 
                          : (isDarkMode ? Colors.white54 : Colors.black54),
                    ),
                  ),
                  if (isMe) 
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.done_all, 
                        size: 16, 
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 