import 'dart:math';

import 'package:location/location.dart' as loc;
Future<Map<String, double>> getLocationBounds() async {
  final double radiusInKm = 50.0;
  loc.Location location = loc.Location();

  // Step 1: Check and request permission
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
  }

  loc.PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == loc.PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != loc.PermissionStatus.granted) {
      return Future.error('Location permissions are denied');
    }
  }

  // Step 2: Get the current location
  loc.LocationData currentLocation = await location.getLocation();

  double currentLat = currentLocation.latitude!;
  double currentLon = currentLocation.longitude!;

  // Step 3: Calculate bounding box based on radius
  double radiusInDegrees = radiusInKm / 111.32;

  double latMin = currentLat - radiusInDegrees;
  double latMax = currentLat + radiusInDegrees;
  double lonMin = currentLon - radiusInDegrees / cos(currentLat * pi / 180);
  double lonMax = currentLon + radiusInDegrees / cos(currentLat * pi / 180);
  return {
    "lonMin": lonMin,
    "latMin": latMin,
    "lonMax": lonMax,
    "latMax": latMax,
  };
}