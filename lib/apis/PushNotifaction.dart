import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  static const String _fcmURL = 'https://fcm.googleapis.com/v1/projects/globe-gaze/messages:send';
  // Function to obtain OAuth 2.0 access token using the service account
  static Future<String> _getAccessToken() async {
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
      jsonDecode(await rootBundle.loadString('assets/privetApi/globe-gaze-firebase-adminsdk-nsu48-dfec9e877b.json')),
    );
    // List of required scopes for FCM
    final List<String> scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // Get an authenticated HTTP client with OAuth 2.0 token
    final AuthClient authClient = await clientViaServiceAccount(serviceAccountCredentials, scopes);
    return authClient.credentials.accessToken.data;
  }
  // Function to send push notification
  static Future<void> sendPushNotification(String deviceToken, String name , String msg) async {
    try {
      // Obtain the OAuth 2.0 access token
      String accessToken = await _getAccessToken();

      // Payload for the notification
      final Map<String, dynamic> payload = {
        "message": {
          "token":deviceToken ,
          "notification": {
            "title": name,
            "body": msg,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "status": "done"
          },
          "android": {
            "notification": {
              "sound": "default",
              "channel_id": "globegazemsg",
            }
          }
        }
      };

      // Making the POST request to FCM API with OAuth access token
      final response = await http.post(
        Uri.parse(_fcmURL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );
      // Check the response status
      if (response.statusCode == 200) {
        log('Push notification sent successfully.');
      } else {
        log('Failed to send notification. Response: ${response.body}');
      }
    } catch (e) {
      log('Error sending push notification: $e');
    }
  }
}
