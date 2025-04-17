import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ZegoCloudService {
  static final ZegoCloudService _instance = ZegoCloudService._internal();
  factory ZegoCloudService() => _instance;
  ZegoCloudService._internal();

  static const int appID = 1891405710;
  static const String appSign = 'c3ba66a222ce3a9122807b10020333eda8b43b5d24e14310c3155bf779213356';

  bool _isInitialized = false;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Check if the device has internet connectivity
  Future<bool> _checkInternetConnectivity() async {
    try {
      debugPrint('🔍 [ZegoCloud] Checking internet connectivity');
      
      // Try to resolve a common DNS name
      final lookupResult = await InternetAddress.lookup('google.com');
      if (lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty) {
        debugPrint('✅ [ZegoCloud] Internet connectivity check passed');
        return true;
      }
      
      debugPrint('❌ [ZegoCloud] Internet connectivity check failed - could not resolve DNS');
      return false;
    } on SocketException catch (e) {
      debugPrint('❌ [ZegoCloud] Internet connectivity check failed with socket exception: $e');
      return false;
    } catch (e) {
      debugPrint('❌ [ZegoCloud] Internet connectivity check failed with unexpected error: $e');
      return false;
    }
  }

  // Check if Firebase/Firestore is accessible
  Future<bool> _checkFirestoreConnectivity() async {
    try {
      debugPrint('🔍 [ZegoCloud] Checking Firestore connectivity');
      
      // Try to resolve the Firestore hostname specifically
      final lookupResult = await InternetAddress.lookup('firestore.googleapis.com');
      if (lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty) {
        debugPrint('✅ [ZegoCloud] Firestore connectivity check passed');
        return true;
      }
      
      debugPrint('❌ [ZegoCloud] Firestore connectivity check failed - could not resolve DNS');
      return false;
    } on SocketException catch (e) {
      debugPrint('❌ [ZegoCloud] Firestore connectivity check failed with socket exception: $e');
      return false;
    } catch (e) {
      debugPrint('❌ [ZegoCloud] Firestore connectivity check failed with unexpected error: $e');
      return false;
    }
  }

  // Show network issue dialog with options
  Future<bool> _showNetworkIssueDialog(BuildContext context, {bool isFirestoreSpecific = false}) async {
    if (!context.mounted) return false;
    
    final String title = isFirestoreSpecific ? 'Firestore Connection Issue' : 'Network Connectivity Issue';
    final String message = isFirestoreSpecific
        ? 'Unable to connect to Firebase services. This may be due to network restrictions, a firewall, or offline mode.'
        : 'Please check your internet connection and try again.';
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 10),
            if (isFirestoreSpecific) 
              const Text(
                'Error: Unable to resolve host "firestore.googleapis.com"',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            const SizedBox(height: 16),
            const Text(
              'Would you like to try a direct call that does not require Firebase?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
            child: const Text('Try Direct Call'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    // First check internet connectivity
    final hasInternet = await _checkInternetConnectivity();
    if (!hasInternet) {
      debugPrint('⚠️ [ZegoCloud] No internet connectivity detected during initialization');
      // We still proceed with initialization but with a warning, as the check might fail in some environments
    }

    // Check Firestore connectivity specifically
    final hasFirestore = await _checkFirestoreConnectivity();
    if (!hasFirestore) {
      debugPrint('⚠️ [ZegoCloud] No Firestore connectivity detected during initialization');
      // We still proceed but with a warning - this is the likely source of the issue
    }

    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        debugPrint('🔍 [ZegoCloud] Initializing ZegoUIKit (attempt ${retryCount + 1})');
        // Initialize ZegoUIKit
        await ZegoUIKit().init(
          appID: appID,
          appSign: appSign,
        );
        debugPrint('✅ [ZegoCloud] ZegoUIKit initialized successfully');

        // Try initializing Signaling Plugin only if we have Firestore connectivity
        if (hasFirestore) {
          debugPrint('🔍 [ZegoCloud] Initializing Signaling Plugin');
          await ZegoUIKitPrebuiltCallInvitationService().init(
            appID: appID,
            appSign: appSign,
            userID: DateTime.now().millisecondsSinceEpoch.toString(),
            userName: "user_${DateTime.now().millisecondsSinceEpoch}",
            plugins: [ZegoUIKitSignalingPlugin()],
            requireConfig: (ZegoCallInvitationData data) {
              debugPrint('🔍 [ZegoCloud] Setting up call config');
              return ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                ..turnOnCameraWhenJoining = true
                ..turnOnMicrophoneWhenJoining = true
                ..useSpeakerWhenJoining = true;
            },
          );
          debugPrint('✅ [ZegoCloud] Signaling Plugin initialized successfully');
        } else {
          debugPrint('⚠️ [ZegoCloud] Skipping Signaling Plugin initialization due to Firestore connectivity issues');
        }

        _isInitialized = true;
        break;
      } catch (e) {
        retryCount++;
        debugPrint('❌ [ZegoCloud] Failed to initialize ZegoCloud (attempt $retryCount): $e');
        debugPrint('🔍 [ZegoCloud] Error details: ${e.toString()}');
        
        // Check for specific DNS resolution error
        if (e.toString().contains('firestore.googleapis.com') && 
            e.toString().contains('Unable to resolve host')) {
          debugPrint('⚠️ [ZegoCloud] Detected DNS resolution error for Firestore - this is likely a network issue');
        }
        
        if (e.toString().contains('firebase')) {
          debugPrint('⚠️ [ZegoCloud] Firebase-related error detected');
        }
        if (e.toString().contains('firestore')) {
          debugPrint('⚠️ [ZegoCloud] Firestore-related error detected');
        }
        if (e.toString().contains('unavailable')) {
          debugPrint('⚠️ [ZegoCloud] Service unavailability detected');
        }
        
        if (retryCount < maxRetries) {
          debugPrint('🔄 [ZegoCloud] Retrying in ${retryDelay.inSeconds * retryCount} seconds');
          await Future.delayed(retryDelay * retryCount);
        } else {
          // If we've exhausted all retries, try a more basic initialization
          try {
            debugPrint('🔍 [ZegoCloud] Attempting basic initialization without signaling');
            await ZegoUIKit().init(
              appID: appID,
              appSign: appSign,
            );
            debugPrint('✅ [ZegoCloud] Basic initialization successful');
            _isInitialized = true;
            break;
          } catch (e2) {
            debugPrint('❌ [ZegoCloud] Failed even basic initialization: $e2');
            debugPrint('🔍 [ZegoCloud] Error details: ${e2.toString()}');
            rethrow;
          }
        }
      }
    }
  }

  // Fallback direct call method when Firebase/Signaling is unavailable
  Future<void> startDirectCall(
    BuildContext context,
    String callID, 
    String userID,
    String userName,
  ) async {
    try {
      // Request permissions first
      await [Permission.camera, Permission.microphone].request();
      
      if (!_isInitialized) {
        // Try basic initialization if not already initialized
        await ZegoUIKit().init(
          appID: appID,
          appSign: appSign,
        );
        _isInitialized = true;
      }
      
      // Simple call configuration
      final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..turnOnCameraWhenJoining = true
        ..turnOnMicrophoneWhenJoining = true
        ..useSpeakerWhenJoining = true;
      
      // Configure UI elements
      config.bottomMenuBarConfig = ZegoBottomMenuBarConfig(
        buttons: [
          ZegoMenuBarButtonName.toggleCameraButton,
          ZegoMenuBarButtonName.toggleMicrophoneButton,
          ZegoMenuBarButtonName.switchCameraButton,
          ZegoMenuBarButtonName.switchAudioOutputButton,
          ZegoMenuBarButtonName.hangUpButton,
        ],
      );
      
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ZegoUIKitPrebuiltCall(
              appID: appID,
              appSign: appSign,
              userID: userID,
              userName: userName,
              callID: callID,
              config: config,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in direct call: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start call: $e')),
        );
      }
    }
  }

  Future<void> joinGroupCall(
    BuildContext context,
    String groupId,
    String userId,
    String userName,
    String groupName,
  ) async {
    debugPrint('🔍 [ZegoCloud] Attempting to join group call: $groupId');
    
    // Check Firebase connectivity before proceeding
    final hasFirestoreConnection = await _checkFirestoreConnectivity();
    if (!hasFirestoreConnection) {
      debugPrint('⚠️ [ZegoCloud] Firestore connectivity issue detected before joining call');
      
      // Show network issue dialog
      final shouldTryDirectCall = await _showNetworkIssueDialog(context, isFirestoreSpecific: true);
      if (shouldTryDirectCall && context.mounted) {
        debugPrint('🔍 [ZegoCloud] User chose to try direct call due to connectivity issue');
        await startDirectCall(
          context,
          'direct_call_$groupId',
          userId,
          userName,
        );
        return;
      } else if (!shouldTryDirectCall) {
        // User cancelled, do not proceed
        return;
      }
      // If for some reason we proceed despite the issue, log that
      debugPrint('⚠️ [ZegoCloud] Proceeding with call attempt despite Firestore connectivity issues');
    }
    
    try {
      if (!_isInitialized) {
        debugPrint('🔍 [ZegoCloud] Service not initialized, initializing now');
        await initialize();
      }

      // Configure call settings
      debugPrint('🔍 [ZegoCloud] Configuring group call');
      final config = ZegoUIKitPrebuiltCallConfig.groupVideoCall()
        ..turnOnCameraWhenJoining = true
        ..turnOnMicrophoneWhenJoining = true
        ..useSpeakerWhenJoining = true;

      // Configure bottom menu bar
      config.bottomMenuBarConfig = ZegoBottomMenuBarConfig(
        buttons: [
          ZegoMenuBarButtonName.toggleCameraButton,
          ZegoMenuBarButtonName.toggleMicrophoneButton,
          ZegoMenuBarButtonName.switchCameraButton,
          ZegoMenuBarButtonName.switchAudioOutputButton,
          ZegoMenuBarButtonName.hangUpButton,
        ],
      );

      debugPrint('🔍 [ZegoCloud] Launching call UI');
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ZegoUIKitPrebuiltCall(
              appID: appID,
              appSign: appSign,
              userID: userId,
              userName: userName,
              callID: 'group_call_$groupId',
              config: config,
              plugins: hasFirestoreConnection ? [ZegoUIKitSignalingPlugin()] : [],  // Only use signaling if Firestore is available
            ),
          ),
        );
      }
      debugPrint('✅ [ZegoCloud] Call UI launched successfully');
    } catch (error) {
      debugPrint('❌ [ZegoCloud] Error joining group call: $error');
      debugPrint('🔍 [ZegoCloud] Error type: ${error.runtimeType}');
      debugPrint('🔍 [ZegoCloud] Detailed error: ${error.toString()}');
      
      // Check for specific DNS resolution error
      bool isDnsResolutionError = false;
      if (error.toString().contains('firestore.googleapis.com') && 
          error.toString().contains('Unable to resolve host')) {
        debugPrint('⚠️ [ZegoCloud] Detected DNS resolution error for Firestore - this is a network issue');
        isDnsResolutionError = true;
      }
      
      // Log more specific error details
      if (error.toString().contains('firebase')) {
        debugPrint('⚠️ [ZegoCloud] Firebase-related error detected');
      }
      if (error.toString().contains('firestore')) {
        debugPrint('⚠️ [ZegoCloud] Firestore-related error detected');
      }
      if (error.toString().contains('cloud_firestore/unavailable')) {
        debugPrint('⚠️ [ZegoCloud] Specific error: Cloud Firestore unavailable');
      }
      if (error.toString().contains('network')) {
        debugPrint('⚠️ [ZegoCloud] Possible network issue detected');
      }
      
      // If the error is DNS resolution or Firestore unavailable, try direct call as fallback
      if (isDnsResolutionError || error.toString().contains('cloud_firestore/unavailable')) {
        debugPrint('🔄 [ZegoCloud] Attempting fallback to direct call due to DNS/Firestore issue');
        if (context.mounted) {
          bool shouldTryDirectCall = await _showNetworkIssueDialog(context, isFirestoreSpecific: true);
          
          if (shouldTryDirectCall && context.mounted) {
            debugPrint('🔍 [ZegoCloud] User chose to try direct call');
            await startDirectCall(
              context, 
              'direct_call_$groupId',
              userId,
              userName,
            );
            return;
          }
        }
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join call: $error')),
        );
      }
    }
  }

  Future<void> sendCallInvitation({
    required BuildContext context,
    required String targetUserId,
    required String targetUserName,
    bool isVideoCall = true,
  }) async {
    debugPrint('🔍 [ZegoCloud] Sending call invitation to $targetUserName ($targetUserId)');
    try {
      if (!_isInitialized) {
        debugPrint('🔍 [ZegoCloud] Service not initialized, initializing now');
        await initialize();
      }

      final callID = DateTime.now().millisecondsSinceEpoch.toString();
      final invitees = [ZegoCallUser(targetUserId, targetUserName)];
      debugPrint('🔍 [ZegoCloud] Created call ID: $callID');

      // For call invitations, we need to use the config directly
      debugPrint('🔍 [ZegoCloud] Sending invitation via signaling service');
      await ZegoUIKitPrebuiltCallInvitationService().send(
        callID: callID,
        invitees: invitees,
        customData: '',
        isVideoCall: isVideoCall,
      );
      debugPrint('✅ [ZegoCloud] Call invitation sent successfully');
    } catch (e) {
      debugPrint('❌ [ZegoCloud] Error sending call invitation: $e');
      debugPrint('🔍 [ZegoCloud] Error type: ${e.runtimeType}');
      debugPrint('🔍 [ZegoCloud] Detailed error: ${e.toString()}');
      
      // Log more specific error details
      if (e.toString().contains('firebase')) {
        debugPrint('⚠️ [ZegoCloud] Firebase-related error detected');
      }
      if (e.toString().contains('firestore')) {
        debugPrint('⚠️ [ZegoCloud] Firestore-related error detected');
      }
      if (e.toString().contains('cloud_firestore/unavailable')) {
        debugPrint('⚠️ [ZegoCloud] Specific error: Cloud Firestore unavailable');
      }
      if (e.toString().contains('network')) {
        debugPrint('⚠️ [ZegoCloud] Possible network issue detected');
      }
      
      // If the error is related to Firebase, try direct call
      if (e.toString().contains('cloud_firestore/unavailable')) {
        debugPrint('🔄 [ZegoCloud] Attempting fallback to direct call');
        if (context.mounted) {
          bool shouldTryDirectCall = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Connection Issue'),
              content: const Text(
                'The invitation service is currently unavailable. Would you like to try a direct call instead?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Try Direct Call'),
                ),
              ],
            ),
          ) ?? false;
          
          if (shouldTryDirectCall && context.mounted) {
            debugPrint('🔍 [ZegoCloud] User chose to try direct call');
            final String userID = DateTime.now().millisecondsSinceEpoch.toString();
            final String directCallID = 'direct_${userID}_${targetUserId}';
            debugPrint('🔍 [ZegoCloud] Created direct call ID: $directCallID');
            
            // Show a message to the user about how to join
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tell $targetUserName to join call with ID: $directCallID'),
                duration: const Duration(seconds: 10),
                action: SnackBarAction(
                  label: 'Copy ID',
                  onPressed: () {
                    // You would implement clipboard copy here
                    debugPrint('🔍 [ZegoCloud] User copied call ID');
                  },
                ),
              ),
            );
            
            await startDirectCall(
              context,
              directCallID,
              userID,
              "User",
            );
            return;
          }
        }
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send invitation: $e')),
        );
      }
    }
  }

  void uninitialize() {
    if (_isInitialized) {
      ZegoUIKit().uninit();
      try {
        ZegoUIKitPrebuiltCallInvitationService().uninit();
      } catch (e) {
        debugPrint('Error uninitializing invitation service: $e');
      }
      _isInitialized = false;
    }
  }
}