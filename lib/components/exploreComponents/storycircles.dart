import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StoryCircle extends StatelessWidget {
  final String? image;
  final String userName;
  final bool isAddStory;

  const StoryCircle({
    Key? key,
    this.image,
    required this.userName,
    this.isAddStory = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {

          },
          child: CircleAvatar(
            radius: 32,
            backgroundColor: isAddStory ? Colors.blue : Colors.grey.shade300,
            child: isAddStory
                ? Icon(Icons.add, color: Colors.white, size: 32)
                : ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                image ?? 'assets/default_user.png',
                height: 64,
                width: 64,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          userName,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}