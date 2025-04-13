import 'dart:async';

import 'package:get/get.dart';

import '../../apis/datamodel.dart';
import '../../locationservices/locationForSUGGESATION.dart';
import '../../locationservices/current location.dart' as location_service;

class ExploreController extends GetxController {
  var places = [].obs;
  var isLoading = true.obs;
  var location = "Fetching location...".obs;
  int currentPage = 0;
  int pageSize = 10;
  bool hasMorePosts = true;

  @override
  void onInit() {
    super.onInit();
    fetchPlaces();
    startAutoPageSwitch();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await fetchPlaces();
      await updateLocationText();
    } catch (e) {
      print('Error refreshing data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMorePosts() async {
    if (!hasMorePosts || isLoading.value) return;
    
    isLoading.value = true;
    try {
      // Implement pagination logic here
      // For now, we'll just set hasMorePosts to false
      hasMorePosts = false;
    } catch (e) {
      print('Error loading more posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPlaces() async {
    isLoading.value = true;
    try {
      Map<String, double>? currentloc = await getLocationBounds();
      if (currentloc != null) {
        double lonMin = currentloc['lonMin']!;
        double latMin = currentloc['latMin']!;
        double lonMax = currentloc['lonMax']!;
        double latMax = currentloc['latMax']!;
        var fetchedPlaces = await PlaceService().fetchPlaces(lonMin, latMin, lonMax, latMax);
        places.assignAll(fetchedPlaces);
      } else {
        places.clear();
      }
    } catch (e) {
      print('Error fetching places: $e');
      places.clear();
    } finally {
      isLoading.value = false;
      updateLocationText();
    }
  }

  Future<void> updateLocationText() async {
    try {
      Map<String, String>? locationData = await location_service.fetchLocation();
      if (locationData != null) {
        location.value = "${locationData['locality']}, ${locationData['country']}";
      } else {
        location.value = "Location not available";
      }
    } catch (e) {
      print('Error updating location text: $e');
      location.value = "Location not available";
    }
  }

  void startAutoPageSwitch() {
    // Automatically switch between pages in PageView every 10 seconds
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (places.isNotEmpty) {
        if (currentPage < places.length - 1) {
          currentPage++;
        } else {
          currentPage = 0;
        }
        update();
      }
    });
  }
}
