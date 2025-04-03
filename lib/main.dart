import 'dart:developer';

import 'package:email_otp/email_otp.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; 
import 'package:globegaze/Screens/home_screens/search.dart';
import 'package:globegaze/components/postComponents/group_explorer_postcard.dart';
import 'package:globegaze/themes/appTheme.dart';
import 'package:provider/provider.dart';
import 'Providers/postProviders/imageMediaProviders.dart';
import 'Providers/postProviders/locationProvider.dart';
import 'Splash_Screen.dart';
import 'apis/APIs.dart';

late Size mq;

// Initialize the notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();

  // Email OTP configuration (unchanged)
  EmailOTP.config(
    appName: 'Globe Gaze',
    otpType: OTPType.numeric,
    emailTheme: EmailTheme.v1,
    otpLength: 6,
  );
  EmailOTP.setTemplate(
    template: '''
  <div style="background-color: #f7f7f7; padding: 40px; font-family: Arial, sans-serif;">
    <div style="background-color: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); max-width: 600px; margin: 0 auto;">
      <h2 style="color: #2c3e50; font-size: 24px; text-align: center;">{{appName}} Password Reset</h2>
      <hr style="border: none; border-bottom: 1px solid #e1e1e1; margin: 20px 0;">
      <p style="color: #2c3e50; font-size: 16px;">Dear User,</p>
      <p style="color: #2c3e50; font-size: 16px;">We received a request to reset your password for your {{appName}} account. Please use the following One-Time Password (OTP) to proceed:</p>
      <div style="background-color: #f0f4f8; padding: 15px; border-radius: 8px; text-align: center; font-size: 22px; font-weight: bold; color: #43dd8c; letter-spacing: 2px; margin: 20px 0;">
        {{otp}}
      </div>
      <p style="color: #2c3e50; font-size: 16px;">This OTP is valid for 5 minutes. If you did not request a password reset, please ignore this email.</p>
      <p style="color: #2c3e50; font-size: 16px;">If you have any questions or concerns, feel free to contact our support team.</p>
      <p style="color: #7f8c8d; font-size: 14px; text-align: center; margin-top: 40px;">Thank you for choosing {{appName}}.</p>
    </div>
  </div>
  ''',
  );

  // Initialize flutter_local_notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // Use your app icon
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create the notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'globegazemsg', // Same ID as before
    'Message', // Same name as before
    description: 'User Message Notification', // Same description as before
    importance: Importance.high, // Matches IMPORTANCE_HIGH
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  log('Notification channel "globegazemsg" registered');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MediaProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    log("Global lifecycle observer registered");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    log("Global lifecycle observer removed");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("Global lifecycle state changed: $state");
    switch (state) {
      case AppLifecycleState.resumed:
        log("App resumed");
        Apis.updateActiveStatus(true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        Apis.updateActiveStatus(false);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Globe Gaze',
      debugShowCheckedModeBanner: false,
      darkTheme: darkTheme,
      theme: lightTheme,
      themeMode: ThemeMode.system,
      home:  MyHomePage(),
    );
  }
}