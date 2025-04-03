import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:globegaze/Screens/home_screens/main_home.dart';
import 'package:intl/intl.dart';
import '../../themes/colors.dart';
import '../customTextFieldwidget.dart';

Widget buildCreatePostForm(
    BuildContext context,
    Future<void> Function(BuildContext context, bool isStart) selectDate,
    DateTime? endDate,
    DateTime? startDate,
    ) {
  final ValueNotifier<List<TextEditingController>> destinationControllers = ValueNotifier([TextEditingController()]);
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _travelersCountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _itineraryController = TextEditingController();
  final TextEditingController _preferredAgeController = TextEditingController();
  final TextEditingController _genderPreferenceController = TextEditingController();
  final TextEditingController _accommodationController = TextEditingController();
  final TextEditingController _transportationController = TextEditingController();
  final TextEditingController _organizerNameController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _socialMediaHandleController = TextEditingController();
  final TextEditingController _travelInterestsController = TextEditingController();
  final TextEditingController _experienceLevelController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _healthRestrictionsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
            const SnackBar(content: Text('You must be logged in to create a post')),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('travel_posts').add({
          'destinations': destinations,
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
          'duration': _durationController.text.trim(),
          'itinerary': _itineraryController.text.trim(),
          'travelersCount': _travelersCountController.text.trim(),
          'preferredAge': _preferredAgeController.text.trim(),
          'genderPreference': _genderPreferenceController.text.trim(),
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
          'createdBy': currentUser.uid, // Add the current user's UID
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainHome()));
      } catch (e) {
        print("Error creating post: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create post: $e")),
        );
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
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          controllers.add(TextEditingController());
                          destinationControllers.value = List.from(controllers);
                        },
                        icon: const Icon(Icons.add, color: Colors.blue),
                        label:  Text("Add Another Destination",style: TextStyle(color: hintColor(context)),),
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
                    title: Text(startDate == null
                        ? 'Start Date'
                        : 'Start Date: ${DateFormat('yMMMd').format(startDate!)}',style: TextStyle(color: textColor(context),),),
                    trailing:  Icon(Icons.calendar_today,color: hintColor(context),),
                    onTap: () => selectDate(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ListTile(
                    title: Text(endDate == null
                        ? 'End Date'
                        : 'End Date: ${DateFormat('yMMMd').format(endDate!)}',style: TextStyle(color: textColor(context),),),
                    trailing:  Icon(Icons.calendar_today,color: hintColor(context),),
                    onTap: () => selectDate(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _durationController, icon: CupertinoIcons.time, placeholder: 'Duration (days)'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _itineraryController, icon: CupertinoIcons.book, placeholder: 'Itinerary'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _travelersCountController, icon: CupertinoIcons.person_2, placeholder: 'Number of Travelers'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _preferredAgeController, icon: CupertinoIcons.calendar, placeholder: 'Preferred Age Group'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _genderPreferenceController, icon: CupertinoIcons.person_circle, placeholder: 'Gender Preference'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _budgetController, icon: CupertinoIcons.money_dollar, placeholder: 'Budget (per person)'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _accommodationController, icon: CupertinoIcons.bed_double, placeholder: 'Accommodation Type'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _transportationController, icon: CupertinoIcons.car_detailed, placeholder: 'Mode of Transportation'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _organizerNameController, icon: CupertinoIcons.person_alt_circle, placeholder: 'Organizer Name'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _contactInfoController, icon: CupertinoIcons.phone, placeholder: 'Contact Information'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _socialMediaHandleController, icon: CupertinoIcons.at, placeholder: 'Social Media Handle (optional)'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _travelInterestsController, icon: CupertinoIcons.compass, placeholder: 'Travel Interests'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _experienceLevelController, icon: CupertinoIcons.chart_bar, placeholder: 'Experience Level'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _emergencyContactController, icon: CupertinoIcons.heart, placeholder: 'Emergency Contact (optional)'),
            const SizedBox(height: 16),
            buildProfileTextField(context, controller: _healthRestrictionsController, icon: CupertinoIcons.info, placeholder: 'Health or Dietary Restrictions'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createPost,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, // Text color
                backgroundColor: PrimaryColor, // Button background color
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18), // Smooth edges
                ),
                elevation: 4, // Shadow effect
              ),
              child: const Text('Create Post'),
            ),
          ],
        ),
      ),
    ),
  );
}