import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ZegoCloudService {
  static final ZegoCloudService _instance = ZegoCloudService._internal();
  factory ZegoCloudService() => _instance;
  ZegoCloudService._internal();

  // ZegoCloud credentials
  static const int appID = 1891405710;
  static const String appSign = 'c3ba66a222ce3a9122807b10020333eda8b43b5d24e14310c3155bf779213356';
  
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize ZegoUIKit - Note: ZegoUIKit is initialized through the prebuilt call widget
    // No need for manual initialization
    _isInitialized = true;
  }

  // Get a video call widget that can be used in any screen
  ZegoUIKitPrebuiltCall getGroupCallWidget({
    required String callID,
    required String userID,
    required String userName,
    required ZegoUIKitPrebuiltCallConfig config,
  }) {
    return ZegoUIKitPrebuiltCall(
      appID: appID,
      appSign: appSign,
      userID: userID,
      userName: userName,
      callID: callID,
      config: config,
    );
  }

  // Configure a group video call with default settings
  ZegoUIKitPrebuiltCallConfig getGroupCallConfig() {
    return ZegoUIKitPrebuiltCallConfig.groupVideoCall()
      ..turnOnCameraWhenJoining = true
      ..turnOnMicrophoneWhenJoining = true
      ..useSpeakerWhenJoining = true;
  }

  // Method to join a call
  void joinGroupCall(BuildContext context, String groupId, String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => getGroupCallWidget(
          callID: 'group_call_$groupId',
          userID: userId,
          userName: userName,
          config: getGroupCallConfig(),
        ),
      ),
    );
  }
} 