import 'dart:async'; // Import to use the Timer
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/Screens/login_signup_screens/new_password.dart';
import 'package:globegaze/components/Elevated_button.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:pinput/pinput.dart';
import '../../themes/dark_light_switch.dart';

class otp_screen extends StatefulWidget {
  const otp_screen({super.key});

  @override
  State<otp_screen> createState() => _otp_screenState();
}

class _otp_screenState extends State<otp_screen> {
  var _userPin;
  bool _isResendEnabled = false; // Initially, the resend button is disabled
  int _resendCountdown = 30; // Countdown for 30 seconds
  Timer? _timer; // Timer for countdown
  String _otpStatus = ""; // To store OTP status (e.g., expired message)

  @override
  void initState() {
    super.initState();
    _startCountdown(); // Start the countdown when the screen opens
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer when the widget is disposed
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _resendCountdown = 30;
      _isResendEnabled = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _isResendEnabled = true;
          _timer?.cancel(); // Stop the timer when the countdown ends
        }
      });
    });
  }

  Future<void> _verifyOTP() async {
    // Check if OTP is expired
    if (await EmailOTP.isOtpExpired()) {
      setState(() {
        _otpStatus = "OTP has expired. Please request a new OTP.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP has expired"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Proceed to verify the OTP
      final isRight = EmailOTP.verifyOTP(otp: _userPin);
      if (isRight) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NewPassword()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid OTP"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black),
      decoration: BoxDecoration(
        color: Colors.greenAccent.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        title: const Text('OTP'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 40),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/png_jpeg_images/otp1.png'),
              ),
              const SizedBox(height: 18),
              Text(
                'Verification',
                style: TextStyle(
                  color: LightDark(isDarkMode),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: const Text(
                  'Enter the code sent to your phone',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth / 16, right: screenWidth / 16),
                child: Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: Colors.green),
                    ),
                  ),
                  onCompleted: (pin) {
                    _userPin = pin;
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 180,
                height: 50,
                child: Button(
                  bgColor: PrimaryColor,
                  fgColor: Colors.white,
                  text: 'Verify',
                  fontSize: 20.0,
                  onPress: _verifyOTP,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _otpStatus.isEmpty ? "Didn't you receive any code?" : _otpStatus,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: LightDark(isDarkMode),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: _isResendEnabled
                    ? () {
                  // Resend OTP logic here
                  EmailOTP.sendOTP(email: 'user_email@example.com'); // Replace with actual email
                  _startCountdown(); // Restart the countdown
                }
                    : null, // Disable button if resend is not allowed
                style: TextButton.styleFrom(
                  foregroundColor: _isResendEnabled ? PrimaryColor : Colors.grey,
                ),
                child: const Text(
                  "Resend OTP",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              if (!_isResendEnabled)
                Text(
                  "Resend available in $_resendCountdown seconds",
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
