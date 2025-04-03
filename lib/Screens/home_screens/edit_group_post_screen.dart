import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:globegaze/components/customTextFieldwidget.dart';
import 'package:globegaze/components/custombutton.dart';

class EditGroupPostScreen extends StatefulWidget {
  final String postId;

  const EditGroupPostScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<EditGroupPostScreen> createState() => _EditGroupPostScreenState();
}

class _EditGroupPostScreenState extends State<EditGroupPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _postData;
  bool _isLoading = true;

  // Controllers for form fields
  late TextEditingController _destinationController;
  late TextEditingController _budgetController;
  late TextEditingController _durationController;
  late TextEditingController _travelersController;
  late TextEditingController _itineraryController;
  late TextEditingController _organizerNameController;
  late TextEditingController _contactInfoController;
  late TextEditingController _socialMediaHandleController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _healthRestrictionsController;
  late TextEditingController _preferredAgeController;
  late TextEditingController _genderPreferenceController;
  late TextEditingController _accommodationController;
  late TextEditingController _transportationController;
  late TextEditingController _experienceLevelController;
  late TextEditingController _travelInterestsController;

  @override
  void initState() {
    super.initState();
    // Initialize all controllers with empty values
    _destinationController = TextEditingController();
    _budgetController = TextEditingController();
    _durationController = TextEditingController();
    _travelersController = TextEditingController();
    _itineraryController = TextEditingController();
    _organizerNameController = TextEditingController();
    _contactInfoController = TextEditingController();
    _socialMediaHandleController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _healthRestrictionsController = TextEditingController();
    _preferredAgeController = TextEditingController();
    _genderPreferenceController = TextEditingController();
    _accommodationController = TextEditingController();
    _transportationController = TextEditingController();
    _experienceLevelController = TextEditingController();
    _travelInterestsController = TextEditingController();
    
    _loadPostData();
  }

  Future<void> _loadPostData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('travel_posts')
          .doc(widget.postId)
          .get();

      if (doc.exists) {
        setState(() {
          _postData = doc.data()!;
          // Update controllers with loaded data
          _destinationController.text = _postData['destinations'][0];
          
          // Handle numeric values
          var budget = _postData['budget'];
          if (budget is int) budget = budget.toDouble();
          _budgetController.text = budget?.toString() ?? '';

          var duration = _postData['duration'];
          _durationController.text = duration?.toString() ?? '';

          var travelersCount = _postData['travelersCount'];
          _travelersController.text = travelersCount?.toString() ?? '';

          // Handle text values
          _itineraryController.text = _postData['itinerary'] ?? '';
          _organizerNameController.text = _postData['organizerName'] ?? '';
          _contactInfoController.text = _postData['contactInfo'] ?? '';
          _socialMediaHandleController.text = _postData['socialMediaHandle'] ?? '';
          _emergencyContactController.text = _postData['emergencyContact'] ?? '';
          _healthRestrictionsController.text = _postData['healthRestrictions'] ?? '';
          _preferredAgeController.text = _postData['preferredAge']?.toString() ?? '';
          _genderPreferenceController.text = _postData['genderPreference']?.toString() ?? '';
          _accommodationController.text = _postData['accommodation']?.toString() ?? '';
          _transportationController.text = _postData['transportation']?.toString() ?? '';
          _experienceLevelController.text = _postData['experienceLevel']?.toString() ?? '';
          _travelInterestsController.text = _postData['travelInterests']?.toString() ?? '';
          
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post not found')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading post: $e')),
      );
    }
  }

  Future<void> _updatePost() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Validate required fields
        if (_destinationController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a destination')),
          );
          return;
        }

        // Validate and parse numeric fields
        final budgetText = _budgetController.text.trim().replaceAll(',', '');
        final durationText = _durationController.text.trim();
        final travelersText = _travelersController.text.trim();

        if (budgetText.isEmpty || durationText.isEmpty || travelersText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in all required fields')),
          );
          return;
        }

        // Remove any non-numeric characters except decimal point
        final cleanBudgetText = budgetText.replaceAll(RegExp(r'[^\d.]'), '');
        final cleanDurationText = durationText.replaceAll(RegExp(r'[^\d]'), '');
        final cleanTravelersText = travelersText.replaceAll(RegExp(r'[^\d]'), '');

        final budget = double.tryParse(cleanBudgetText);
        final duration = int.tryParse(cleanDurationText);
        final travelers = int.tryParse(cleanTravelersText);

        if (budget == null || duration == null || travelers == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid numbers for budget, duration, and travelers count')),
          );
          return;
        }

        final updateData = {
          'destinations': [_destinationController.text.trim()],
          'budget': budget,
          'duration': duration,
          'travelersCount': travelers,
          'itinerary': _itineraryController.text.trim(),
          'organizerName': _organizerNameController.text.trim(),
          'contactInfo': _contactInfoController.text.trim(),
          'socialMediaHandle': _socialMediaHandleController.text.trim(),
          'emergencyContact': _emergencyContactController.text.trim(),
          'healthRestrictions': _healthRestrictionsController.text.trim(),
          'preferredAge': _preferredAgeController.text.trim(),
          'genderPreference': _genderPreferenceController.text.trim(),
          'accommodation': _accommodationController.text.trim(),
          'transportation': _transportationController.text.trim(),
          'experienceLevel': _experienceLevelController.text.trim(),
          'travelInterests': _travelInterestsController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('travel_posts')
            .doc(widget.postId)
            .update(updateData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating post: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    _travelersController.dispose();
    _itineraryController.dispose();
    _organizerNameController.dispose();
    _contactInfoController.dispose();
    _socialMediaHandleController.dispose();
    _emergencyContactController.dispose();
    _healthRestrictionsController.dispose();
    _preferredAgeController.dispose();
    _genderPreferenceController.dispose();
    _accommodationController.dispose();
    _transportationController.dispose();
    _experienceLevelController.dispose();
    _travelInterestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Destination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _destinationController, icon: Icons.location_on, placeholder: 'Destination'),
              const SizedBox(height: 16),
              
              Text('Budget (per person)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _budgetController, icon: Icons.attach_money, placeholder: 'Budget (per person)'),
              const SizedBox(height: 16),
              
              Text('Duration (days)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _durationController, icon: Icons.timer, placeholder: 'Duration (days)'),
              const SizedBox(height: 16),
              
              Text('Number of Travelers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _travelersController, icon: Icons.people, placeholder: 'Number of Travelers'),
              const SizedBox(height: 16),
              
              Text('Itinerary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _itineraryController, icon: Icons.list, placeholder: 'Itinerary'),
              const SizedBox(height: 16),
              
              Text('Organizer Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _organizerNameController, icon: Icons.person, placeholder: 'Organizer Name'),
              const SizedBox(height: 16),
              
              Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _contactInfoController, icon: Icons.phone, placeholder: 'Contact Information'),
              const SizedBox(height: 16),
              
              Text('Social Media Handle (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _socialMediaHandleController, icon: Icons.link, placeholder: 'Social Media Handle (optional)'),
              const SizedBox(height: 16),
              
              Text('Emergency Contact (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _emergencyContactController, icon: Icons.emergency, placeholder: 'Emergency Contact (optional)'),
              const SizedBox(height: 16),
              
              Text('Health or Dietary Restrictions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _healthRestrictionsController, icon: Icons.medical_services, placeholder: 'Health or Dietary Restrictions'),
              const SizedBox(height: 16),
              
              Text('Preferred Age Group', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _preferredAgeController, icon: Icons.calendar_today, placeholder: 'Preferred Age Group'),
              const SizedBox(height: 16),
              
              Text('Gender Preference', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _genderPreferenceController, icon: Icons.person_outline, placeholder: 'Gender Preference'),
              const SizedBox(height: 16),
              
              Text('Accommodation Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _accommodationController, icon: Icons.hotel, placeholder: 'Accommodation Type'),
              const SizedBox(height: 16),
              
              Text('Mode of Transportation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _transportationController, icon: Icons.directions_car, placeholder: 'Mode of Transportation'),
              const SizedBox(height: 16),
              
              Text('Experience Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _experienceLevelController, icon: Icons.star, placeholder: 'Experience Level'),
              const SizedBox(height: 16),
              
              Text('Travel Interests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor(context))),
              const SizedBox(height: 8),
              buildProfileTextField(context, controller: _travelInterestsController, icon: Icons.explore, placeholder: 'Travel Interests'),
              const SizedBox(height: 32),
              
              buildButton(
                context: context,
                text: 'Save Changes',
                textColor: Colors.black,
                bgColor: PrimaryColor,
                onTap: _updatePost,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
} 