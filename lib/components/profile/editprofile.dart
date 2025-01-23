import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';
import '../../apis/APIs.dart';
import '../../themes/dark_light_switch.dart';
import '../customTextFieldwidget.dart';

void showEditProfileBottomSheet(
    BuildContext context, {
      required String fullName,
      required String email,
      required String phone,
      required String username,
      required String about,
      required Function(Map<String, dynamic> updatedData) onSaveChanges, // Add callback parameter
    }) async {
  bool check = false;
  TextEditingController fullNameController = TextEditingController(text: fullName);
  TextEditingController emailController = TextEditingController(text: email);
  TextEditingController phoneController = TextEditingController(text: phone);
  TextEditingController usernameController = TextEditingController(text: username);
  TextEditingController aboutController = TextEditingController(text: about);
  ValueNotifier<bool> hasChanges = ValueNotifier(false);

  void checkForChanges() {
    hasChanges.value = fullNameController.text != fullName ||
        emailController.text != email ||
        phoneController.text != phone ||
        usernameController.text != username ||
        aboutController.text != about;
  }
  fullNameController.addListener(checkForChanges);
  emailController.addListener(checkForChanges);
  phoneController.addListener(checkForChanges);
  usernameController.addListener(checkForChanges);
  aboutController.addListener(checkForChanges);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Full Name field
              buildProfileTextField(
                context,
                controller: fullNameController,
                icon: CupertinoIcons.person,
                placeholder: 'Full Name',
              ),
              SizedBox(height: 16),
              // Username field
              buildProfileTextField(
                context,
                controller: usernameController,
                icon: CupertinoIcons.profile_circled,
                placeholder: 'Username',
              ),
              SizedBox(height: 16),
              // Email field
              buildProfileTextField(
                context,
                controller: emailController,
                icon: CupertinoIcons.mail,
                placeholder: 'Email',
              ),
              SizedBox(height: 16),
              // Phone field
              buildProfileTextField(
                context,
                controller: phoneController,
                icon: CupertinoIcons.phone,
                placeholder: 'Phone',
              ),
              SizedBox(height: 16),
              // About field
              buildProfileTextField(
                context,
                controller: aboutController,
                icon: CupertinoIcons.pencil_outline,
                placeholder: 'About',
              ),
              SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: hasChanges,
                builder: (context, value, child) {
                  return SizedBox(
                    width: 200,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PrimaryColor,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: value ? () async {
                        // Collect updated data
                        Map<String, dynamic> updatedData = {};

                        if (fullNameController.text != fullName) {
                          updatedData['FullName'] = fullNameController.text;
                        }
                        if (emailController.text != email) {
                          updatedData['Email'] = emailController.text;
                        }
                        if (phoneController.text != phone) {
                          updatedData['Phone'] = phoneController.text;
                        }
                        if (usernameController.text != username) {
                          updatedData['Username'] = usernameController.text;
                        }
                        if (aboutController.text != about) {
                          updatedData['About'] = aboutController.text;
                        }
                        if (updatedData.isNotEmpty) {
                          try {
                            check = await Apis.updateUserProfile(updatedData);
                            if (check) {
                              onSaveChanges(updatedData);
                            }
                          } catch (e) {
                            log(e.toString());
                          }
                        }
                        Navigator.pop(context);
                      } : null,
                      child: const Center(
                        child: Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}