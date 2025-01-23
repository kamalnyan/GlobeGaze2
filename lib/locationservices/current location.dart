import 'dart:developer';
import 'package:location/location.dart' as loc;
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, String>?> fetchLocation() async {
  try {
    final loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }
    loc.PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == loc.PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != loc.PermissionStatus.granted) {
        return null;
      }
    }
    final loc.LocationData locationData = await location.getLocation();
    final double? latitude = locationData.latitude;
    final double? longitude = locationData.longitude;
    log("$latitude");
    log("$longitude");
    if (latitude == null || longitude == null) {
      log("Both are null ");
      return null;
    }
    final  placemarks = await getLocationDetails(latitude, longitude);
    if (placemarks != null) {
      print("Locality: ${placemarks['locality']}");
      print("Country: ${placemarks['country']}");
      return placemarks;
    } else {
      print("Could not retrieve location details.");
    }
  } catch (e) {
    print("Error fetching placemark: $e");
    return null;
  }
  return null;
}
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
      print("Failed to fetch data. Status code: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error fetching location data: $e");
    return null;
  }
}
