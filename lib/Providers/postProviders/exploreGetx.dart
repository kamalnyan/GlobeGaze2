import 'dart:async';

import 'package:get/get.dart';

import '../../apis/datamodel.dart';
import '../../locationservices/locationForSUGGESATION.dart';

class ExploreController extends GetxController {
  var places = [].obs;
  var isLoading = true.obs;
  var location = "Fetching location...".obs;
  int currentPage = 0;

  @override
  void onInit() {
    super.onInit();
    fetchPlaces();
    startAutoPageSwitch();
  }

  void fetchPlaces() async {
    isLoading.value = true;
    Map<String, double>? currentloc = await getLocationBounds();
    try {
      double lonMin = currentloc['lonMin']!;
      double latMin = currentloc['latMin']!;
      double lonMax = currentloc['lonMax']!;
      double latMax = currentloc['latMax']!;
      var fetchedPlaces = await PlaceService().fetchPlaces(lonMin, latMin, lonMax, latMax);
      places.assignAll(fetchedPlaces);
    } catch (e) {
      print('Error fetching places: $e');
    } finally {
      isLoading.value = false;
      fetchLocation();
    }
  }

   fetchLocation() async {
    Map<String, String>? locationData = await fetchLocation();
    if (locationData != null) {
      location.value = "${locationData['locality']}, ${locationData['country']}";
    } else {
      location.value = "Location not available";
    }
  }

  void startAutoPageSwitch() {
    // Automatically switch between pages in PageView every 10 seconds
    Timer.periodic(Duration(seconds: 10), (timer) {
      if (currentPage < places.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }
      update();
    });
  }
}
