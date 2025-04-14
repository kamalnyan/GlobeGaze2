import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:globegaze/Screens/home_screens/main_home.dart';
import 'package:intl/intl.dart';
import '../../Screens/group_details_screen.dart';
import '../../themes/colors.dart';
import '../../themes/dark_light_switch.dart';
import '../customTextFieldwidget.dart';

Widget buildCreatePostForm(
    BuildContext context,
    Future<void> Function(BuildContext context, bool isStart) selectDate,
    DateTime? endDate,
    DateTime? startDate,
    ) {
  final ValueNotifier<List<TextEditingController>> destinationControllers =
  ValueNotifier([TextEditingController()]);
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final ValueNotifier<int> _travelersCount = ValueNotifier(1);
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _itineraryController = TextEditingController();
  final ValueNotifier<String?> _genderPreference = ValueNotifier(null);
  final TextEditingController _preferredAgeController = TextEditingController();
  final TextEditingController _accommodationController = TextEditingController();
  final TextEditingController _transportationController = TextEditingController();
  final TextEditingController _organizerNameController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _socialMediaHandleController =
  TextEditingController();
  final TextEditingController _travelInterestsController =
  TextEditingController();
  final TextEditingController _experienceLevelController =
  TextEditingController();
  final TextEditingController _emergencyContactController =
  TextEditingController();
  final TextEditingController _healthRestrictionsController =
  TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  // List of gender options
  final List<String> _genderOptions = ['Any', 'Male', 'Female', 'Other'];

  Future<String?> _createGroup() async {
    final String groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return null;
    }

    _isLoading.value = true;

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      // Create a new group document
      final docRef = await _firestore.collection('groups').add({
        'name': groupName,
        'createdBy': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [currentUser.uid],
      });

      return docRef.id;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  void _createPost() async {
    if (_formKey.currentState!.validate()) {
      try {
        final destinations = destinationControllers.value
            .map((c) => c.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();
        if (destinations.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter at least one destination')),
          );
          return;
        }

        // Get current user's UID
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You must be logged in to create a post')),
          );
          return;
        }

        _isLoading.value = true;

        // First create travel post
        final postRef = await FirebaseFirestore.instance.collection('travel_posts').add({
          'destinations': destinations,
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
          'duration': _durationController.text.trim(),
          'itinerary': _itineraryController.text.trim(),
          'travelersCount': _travelersCount.value.toString(),
          'preferredAge': _preferredAgeController.text.trim(),
          'genderPreference': _genderPreference.value,
          'budget': _budgetController.text.trim(),
          'accommodation': _accommodationController.text.trim(),
          'transportation': _transportationController.text.trim(),
          'organizerName': _organizerNameController.text.trim(),
          'contactInfo': _contactInfoController.text.trim(),
          'socialMediaHandle': _socialMediaHandleController.text.trim(),
          'travelInterests': _travelInterestsController.text.trim(),
          'experienceLevel': _experienceLevelController.text.trim(),
          'emergencyContact': _emergencyContactController.text.trim(),
          'healthRestrictions': _healthRestrictionsController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': currentUser.uid,
        });

        // Then create associated group
        final groupId = await _createGroup();

        if (groupId != null) {
          // Link the group to the post
          await postRef.update({
            'groupId': groupId
          });

          // Navigate to home screen after successful creation
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MainHome()));
        }
      } catch (e) {
        print("Error creating post: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create post: $e")),
        );
      } finally {
        _isLoading.value = false;
      }
    }
  }

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ValueListenableBuilder<List<TextEditingController>>(
              valueListenable: destinationControllers,
              builder: (context, controllers, child) {
                return Column(
                  children: [
                    for (int i = 0; i < controllers.length; i++) ...[
                      Row(
                        children: [
                          if (i == 0)
                            Expanded(
                              child: buildProfileTextField(
                                context,
                                controller: _groupNameController,
                                icon: CupertinoIcons.group,
                                placeholder: 'Trip Title',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: buildProfileTextField(
                              context,
                              controller: controllers[i],
                              icon: CupertinoIcons.location,
                              placeholder: 'Destination ${i + 1}',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              if (controllers.length > 1) {
                                controllers.removeAt(i);
                                destinationControllers.value = List.from(controllers);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Align(
                      alignment: Alignment.center,
                      child: TextButton.icon(
                        onPressed: () {
                          controllers.add(TextEditingController());
                          destinationControllers.value = List.from(controllers);
                        },
                        icon: const Icon(Icons.add, color: Colors.blue),
                        label: Text(
                          "Add Another Destination",
                          style: TextStyle(color: hintColor(context)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      startDate == null
                          ? 'Start Date'
                          : 'Start Date: ${DateFormat('yMMMd').format(startDate!)}',
                      style: TextStyle(color: textColor(context)),
                    ),
                    trailing: Icon(Icons.calendar_today, color: hintColor(context)),
                    onTap: () => selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ListTile(
                    title: Text(
                      endDate == null
                          ? 'End Date'
                          : 'End Date: ${DateFormat('yMMMd').format(endDate!)}',
                      style: TextStyle(color: textColor(context)),
                    ),
                    trailing: Icon(Icons.calendar_today, color: hintColor(context)),
                    onTap: () => selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _durationController,
                icon: CupertinoIcons.time,
                placeholder: 'Duration (days)'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _itineraryController,
                icon: CupertinoIcons.book,
                placeholder: 'Itinerary'),
            const SizedBox(height: 16),
            ValueListenableBuilder<int>(
              valueListenable: _travelersCount,
              builder: (context, count, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: isDarkMode(context)
                              ? primaryDarkBlue
                              : neutralLightGrey.withOpacity(0.6),
                        ),
                        child: Icon(CupertinoIcons.person_2, color: PrimaryColor),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDarkMode(context)
                              ? primaryDarkBlue
                              : neutralLightGrey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CupertinoTextField(
                                controller: TextEditingController(text: count.toString()),
                                placeholder: 'Number of Travelers',
                                placeholderStyle: TextStyle(
                                  color: hintColor(context),
                                  fontSize: 16,
                                ),
                                cursorColor: PrimaryColor,
                                style: TextStyle(
                                  color: textColor(context),
                                  decoration: TextDecoration.none,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                maxLines: 1,
                                enabled: false,
                              ),
                            ),
                            if (_travelersCount.value > 1)
                              IconButton(
                                icon:
                                const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  _travelersCount.value--;
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.blue),
                              onPressed: () {
                                _travelersCount.value++;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: _genderPreference,
              builder: (context, gender, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: isDarkMode(context)
                              ? primaryDarkBlue
                              : neutralLightGrey.withOpacity(0.6),
                        ),
                        child: Icon(CupertinoIcons.person_circle,
                            color: PrimaryColor),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDarkMode(context)
                              ? primaryDarkBlue
                              : neutralLightGrey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(22.0),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 16),
                            border: InputBorder.none,
                          ),
                          hint: Text(
                            'Select Gender Preference',
                            style: TextStyle(
                              color: hintColor(context),
                              fontSize: 16,
                            ),
                          ),
                          value: gender,
                          items: _genderOptions.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(
                                option,
                                style: TextStyle(color: textColor(context)),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            _genderPreference.value = newValue;
                          },
                          validator: (value) => value == null
                              ? 'Please select a gender preference'
                              : null,
                          isExpanded: true,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: hintColor(context),
                          ),
                          dropdownColor: isDarkMode(context)
                              ? primaryDarkBlue
                              : neutralLightGrey.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _preferredAgeController,
                icon: CupertinoIcons.calendar,
                placeholder: 'Preferred Age Group'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _budgetController,
                icon: CupertinoIcons.money_dollar,
                placeholder: 'Budget (per person)'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _accommodationController,
                icon: CupertinoIcons.bed_double,
                placeholder: 'Accommodation Type'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _transportationController,
                icon: CupertinoIcons.car_detailed,
                placeholder: 'Mode of Transportation'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _organizerNameController,
                icon: CupertinoIcons.person_alt_circle,
                placeholder: 'Organizer Name'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _contactInfoController,
                icon: CupertinoIcons.phone,
                placeholder: 'Contact Information'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _socialMediaHandleController,
                icon: CupertinoIcons.at,
                placeholder: 'Social Media Handle (optional)'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _travelInterestsController,
                icon: CupertinoIcons.compass,
                placeholder: 'Travel Interests'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _experienceLevelController,
                icon: CupertinoIcons.chart_bar,
                placeholder: 'Experience Level'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _emergencyContactController,
                icon: CupertinoIcons.heart,
                placeholder: 'Emergency Contact (optional)'),
            const SizedBox(height: 16),
            buildProfileTextField(
                context,
                controller: _healthRestrictionsController,
                icon: CupertinoIcons.info,
                placeholder: 'Health or Dietary Restrictions'),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, isLoading, child) {
                  return ElevatedButton(
                    onPressed: isLoading ? null : _createPost,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: PrimaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                    ),
                    child: isLoading
                        ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                    )
                        : const Text('Create Post'),
                  );
                }
            ),
          ],
        ),
      ),
    ),
  );
}