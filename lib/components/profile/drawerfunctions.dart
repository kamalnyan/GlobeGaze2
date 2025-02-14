import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Screens/login_signup_screens/login_with_email_and_passsword.dart';
import '../../Screens/login_signup_screens/new_password.dart';
import '../../apis/APIs.dart';
import '../../themes/colors.dart';
import '../captilizeWords.dart';
import '../dynamicScreenSize.dart';

Future<void> showAboutUsDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: darkBackground,
      title: const Row(
        children: [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            "About Us",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome to our application!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "GlobeGaze is your ultimate travel companion, connecting you with like-minded travelers around the world. Share your experiences, discover top tourist destinations, and get personalized travel suggestions from our chat assistant. Whether you're looking for a travel buddy, exploring new places, or seeking recommendations, GlobeGaze makes every journey more exciting and interactive.",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          Divider(color: Colors.white24),
          SizedBox(height: 8),
          Text(
            "Developer Details:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Name: Kamal Nayan",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          Text(
            "Email: uic.23mca20237@gmail.com",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          Text(
            "Name: Deepankar Singh",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          Text(
            "Email: deepankarsingh1@gmail.com",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          Text(
            "Name: Aryan Bansal",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          Text(
            "Email: aashuagrawal96@gmail.com",
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          SizedBox(height: 16),
          Divider(color: Colors.white24),
          SizedBox(height: 8),
          Text(
            "Thank you for using our app! Your feedback and support help us grow and improve.",
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Close",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

Future<void> confirmAndDelete(BuildContext context, String title, String msg,
    String dltmsg, Function onpressed) async {
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: darkBackground,
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      content: Text(
        msg,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            dltmsg,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
  if (confirm == true) {
    try {
      onpressed();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

Future<void> collectFeedbackAndSend(BuildContext context, String title,
    String msg, String sendButtonLabel, String yourName) async {
  final TextEditingController feedbackController = TextEditingController();
  final screenSize = getScreenSize(context);
  final scallText = screenSize.shortestSide / 600;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: darkBackground,
      title: Row(
        children: [
          const Icon(Icons.feedback, color: PrimaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 28 * scallText,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            msg,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              fontSize: 22 * scallText,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: feedbackController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Type your feedback here...",
              hintStyle:
                  TextStyle(color: Colors.white38, fontSize: 24 * scallText),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Cancel",
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 20 * scallText),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: PrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            String feedback = feedbackController.text.trim();
            if (feedback.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Feedback cannot be empty."),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            try {
              await sendEmail(yourName, feedback);
              Navigator.of(context).pop();
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Failed to send feedback: $error"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text(
            sendButtonLabel,
            style: TextStyle(color: Colors.black, fontSize: 20 * scallText),
          ),
        ),
      ],
    ),
  );
}

Future<void> sendEmail(String userName, String feedback) async {
  if (feedback == null || feedback.isEmpty) {
    feedback = 'No feedback provided';
  }
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'uic.23mca20237@gmail.com',
    query:
        'subject=${Uri.encodeComponent('User Feedback')}&body=${Uri.encodeComponent('GlobeGaze Feedback from $userName:\n\n$feedback')}',
  );
  final canLaunch = await canLaunchUrl(emailUri);
  if (canLaunch) {
    await launchUrl(emailUri);
  } else {
    throw 'Could not launch email client';
  }
}
Future<void>  handleLogout(BuildContext context) async {
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: darkBackground,
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text(
            "Confirm logout",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      content: const Text(
        "Are you sure you want to logout ?",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white70,
          fontSize: 16,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            "Logout",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    ),
  );
  if (confirm == true) {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${capitalizeWords(Apis.me.name)} Logged Out',style: const TextStyle(color: Colors.green),) , backgroundColor: primaryDarkBlue,),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to log out: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
Future<void> handleForget(BuildContext context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => const NewPassword()));
}
