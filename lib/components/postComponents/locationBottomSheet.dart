import 'dart:developer';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/components/isDarkMode.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;

import '../../Providers/postProviders/locationProvider.dart';

void showLocationBottomSheet(BuildContext context) {
  late LocationProvider locationProvider;
  locationProvider = Provider.of<LocationProvider>(context,listen: false);
  ValueNotifier<Map<String, String>?> locationDataNotifier = ValueNotifier(null);
  ValueNotifier<List<Map<String, String>>> searchResultsNotifier = ValueNotifier([]);
  String selectedLocation = "";
  fetchLocation().then((locationData) {
    locationDataNotifier.value = locationData;
  });

  showModalBottomSheet(
    backgroundColor: isDarkMode(context)?darkBackground:neutralLightGrey.withValues(alpha: 0.6),
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
            children: [
               Center(
                child: Text(
                  'Choose a Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor(context)
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoSearchTextField(
                enableIMEPersonalizedLearning: true,
                style:  TextStyle(color: hintColor(context)),
                placeholder: 'Search for a location',
                onChanged: (query) async {
                  if (query.isNotEmpty) {
                    List<Map<String, String>> results = await fetchLocationSuggestions(query);searchResultsNotifier.value = results;
                  } else {
                    searchResultsNotifier.value = [];
                  }
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<Map<String, String>?>(
                valueListenable: locationDataNotifier,
                builder: (context, locationData, child) {
                  if (locationData == null) {
                    return const CupertinoActivityIndicator();
                  } else {
                    return ListTile(
                      leading: Icon(CupertinoIcons.location_solid, color: Colors.blue),
                      title: Text('Current Location',style: TextStyle(color: textColor(context)),),
                      subtitle: Text('${locationData['locality']}, ${locationData['country']}',style: TextStyle(color: hintColor(context)),),
                      onTap: () {
                        selectedLocation = '${locationData['locality']}, ${locationData['country']}';
                        locationProvider.setSelectedLocation(selectedLocation);
                        Navigator.pop(context); // Close the bottom sheet
                        log("Selected Location: $selectedLocation"); // Log for verification
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<List<Map<String, String>>>(
                valueListenable: searchResultsNotifier,
                builder: (context, searchResults, child) {
                  return Column(
                    children: searchResults.map((location) {
                      return ListTile(
                        leading: Icon(CupertinoIcons.map_pin_ellipse, color: Colors.grey),
                        title: Text(location['name'] ?? 'Unknown'),
                        subtitle: Text(location['description'] ?? ''),
                        onTap: () {
                          // Store selected suggested/searched location and close bottom sheet
                          selectedLocation = location['name'] ?? 'Unknown';
                          locationProvider.setSelectedLocation(selectedLocation);
                          Navigator.pop(context); // Close the bottom sheet
                          log("Selected Location: $selectedLocation"); // Log for verification
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Fetch current location coordinates and details
Future<Map<String, String>?> fetchLocation() async {
  try {
    final loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    loc.PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) return null;
    }

    final loc.LocationData locationData = await location.getLocation();
    final double? latitude = locationData.latitude;
    final double? longitude = locationData.longitude;
    log("Latitude: $latitude, Longitude: $longitude");

    if (latitude != null && longitude != null) {
      final placemarks = await getLocationDetails(latitude, longitude);
      if (placemarks != null) return placemarks;
    }
  } catch (e) {
    print("Error fetching location: $e");
  }
  return null;
}
// Fetch location details from OpenStreetMap API
Future<Map<String, String>?> getLocationDetails(double latitude, double longitude) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude',
  );

  try {
    final response = await http.get(url, headers: {'User-Agent': 'GlobeGaze/1.0 (uic.23mca20237@gmail.com)'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final locality = data['address']['city'] ?? data['address']['town'] ?? data['address']['village'] ?? 'Unknown';
      final country = data['address']['country'] ?? 'Unknown';
      return {
        'locality': locality,
        'country': country,
      };
    } else {
      print("Failed to fetch location details. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching location data: $e");
  }
  return null;
}
// Fetch location suggestions based on user input using OpenStreetMap Nominatim API
Future<List<Map<String, String>>> fetchLocationSuggestions(String query) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5',
  );

  try {
    final response = await http.get(url, headers: {'User-Agent': 'GlobeGaze/1.0 (uic.23mca20237@gmail.com)'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map<Map<String, String>>((location) {
        final displayName = location['display_name'] ?? 'Unknown';
        final address = location['address'] ?? {};
        final description = [
          address['city'] ?? address['town'] ?? address['village'] ?? '',
          address['country'] ?? ''
        ].where((element) => element.isNotEmpty).join(', ');
        return {'name': displayName, 'description': description};
      }).toList();
    } else {
      print("Failed to fetch search results. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching search results: $e");
  }
  return [];
}
