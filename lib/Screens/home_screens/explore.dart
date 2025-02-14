import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';
import '../../apis/addPost.dart';
import '../../apis/datamodel.dart';
import '../../components/exploreComponents/suggestion.dart';
import '../../components/postComponents/group_explorer_postcard.dart';
import '../../components/postComponents/locationBottomSheet.dart';
import '../../components/postComponents/new_post.dart';
import '../../locationservices/locationForSUGGESATION.dart';
import '../../themes/colors.dart';
import '../../themes/dark_light_switch.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final ValueNotifier<List<dynamic>> placesNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isLoadingPlacesNotifier = ValueNotifier(true);
  final ValueNotifier<String> locationNotifier =
  ValueNotifier("Fetching location...");

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _pageTimer;

  @override
  void initState() {
    super.initState();
    _getLocation();
    _pageController = PageController(viewportFraction: 0.8);
    // Auto-animate the suggestion pages every 10 seconds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageTimer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
        if (placesNotifier.value.isNotEmpty) {
          if (_currentPage < placesNotifier.value.length - 1) {
            _currentPage++;
          } else {
            _currentPage = 0;
          }
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  /// Fetch the current location and update the locationNotifier.
  Future<void> _getLocation() async {
    Map<String, String>? location = await fetchLocation();
    locationNotifier.value = location != null
        ? "${location['locality']}, ${location['country']}"
        : "Location not available";
    fetchPlaces();
  }

  /// Fetch places data and update the notifiers.
  // Future<void> fetchPlaces() async {
  //   isLoadingPlacesNotifier.value = true;
  //   Map<String, double>? currentloc = await getLocationBounds();
  //   if (currentloc == null) {
  //     isLoadingPlacesNotifier.value = false;
  //     return;
  //   }
  //
  //   try {
  //     double lonMin = currentloc['lonMin']!;
  //     double latMin = currentloc['latMin']!;
  //     double lonMax = currentloc['lonMax']!;
  //     double latMax = currentloc['latMax']!;
  //
  //     List<dynamic> fetchedPlaces =
  //     await PlaceService().fetchPlaces(lonMin, latMin, lonMax, latMax);
  //
  //     // Debug: Print the fetched places
  //     print("Fetched places: $fetchedPlaces");
  //
  //     // Sort places so that the latest ones appear first.
  //     fetchedPlaces.sort((a, b) {
  //       DateTime timeA =
  //       (a['properties']['createdAt'] as Timestamp).toDate();
  //       DateTime timeB =
  //       (b['properties']['createdAt'] as Timestamp).toDate();
  //       return timeB.compareTo(timeA);
  //     });
  //
  //     // Only update if new data is available.
  //     if (fetchedPlaces.isNotEmpty) {
  //       placesNotifier.value = fetchedPlaces;
  //     }
  //   } catch (e) {
  //     print('Error fetching places: $e');
  //   } finally {
  //     isLoadingPlacesNotifier.value = false;
  //     _getLocation();
  //   }
  // }
  Future<void> fetchPlaces() async {
    isLoadingPlacesNotifier.value = true;
    Map<String, double>? currentloc = await getLocationBounds();
    if (currentloc == null) {
      isLoadingPlacesNotifier.value = false;
      return;
    }
    try {
      double lonMin = currentloc['lonMin']!;
      double latMin = currentloc['latMin']!;
      double lonMax = currentloc['lonMax']!;
      double latMax = currentloc['latMax']!;

      List<dynamic> fetchedPlaces =
      await PlaceService().fetchPlaces(lonMin, latMin, lonMax, latMax);
      if (mounted) {
        placesNotifier.value = fetchedPlaces;
        placesNotifier.value .sort((a, b) {
          DateTime timeA = (a['properties']['createdAt'] as Timestamp).toDate();
          DateTime timeB = (b['properties']['createdAt'] as Timestamp).toDate();
          return timeB.compareTo(timeA); // Latest first
        });
      }
    } catch (e) {
      print('Error fetching places: $e');
    } finally {
      isLoadingPlacesNotifier.value = false;
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    _pageTimer?.cancel();
    placesNotifier.dispose();
    isLoadingPlacesNotifier.dispose();
    locationNotifier.dispose();
    super.dispose();
  }

  /// Shimmer skeleton for a post
  Widget buildShimmerPost() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
            )),
            const SizedBox(height: 10),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
            )),
            const SizedBox(height: 10),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
            )),
            const SizedBox(height: 10),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
            )),
            const SizedBox(height: 10),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
            )),
            const SizedBox(height: 10),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
            )),
            const SizedBox(height: 10),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
            )),
            const SizedBox(height: 10),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
            )),
            const SizedBox(height: 10),
            Container(width: double.infinity, height: 200, decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
            )),
            const SizedBox(height: 10),

          ],
        ),
      ),
    );
  }
  /// Build the suggestions section.
  /// If there is previous data, it is shown regardless of the loading state.
  Widget buildPlaceCards() {
    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: placesNotifier,
      builder: (context, places, child) {
        if (places.isNotEmpty) {
          return SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _pageController,
              itemCount: places.length,
              itemBuilder: (context, index) {
                var place = places[index];
                String name = place['properties']['name'] ?? 'Unknown';
                double longitude = place['geometry']['coordinates'][0];
                double latitude = place['geometry']['coordinates'][1];
                int rate = place['properties']['rate'] ?? 0;
                String categories = place['properties']['kinds'] ?? '';

                return FutureBuilder<Map<String, String>?>(
                  future: getLocationDetails(latitude, longitude),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return NonScrollableShimmerCard();
                    } else if (snapshot.hasData) {
                      Map<String, String> locationDetails = snapshot.data!;
                      return DestinationCard(
                        name: name,
                        localty: locationDetails['locality'] ?? 'Unknown locality',
                        Country:
                        locationDetails['country'] ?? 'Unknown country',
                        rate: rate,
                        categories: categories,
                        latitude: latitude,
                        longitude: longitude,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
          );
        } else {
          // No previous data available: show a loading shimmer or a no-data message.
          return ValueListenableBuilder<bool>(
            valueListenable: isLoadingPlacesNotifier,
            builder: (context, isLoading, child) {
              if (isLoading) {
                return  ShimmerCardScroller();
              } else {
                return const Center(child: Text('No places to show'));
              }
            },
          );
        }
      },
    );
  }

  /// Build the posts section.
  Widget buildPostsSection() {
    return StreamBuilder<List<List<Map<String, dynamic>>>>(
      stream: CombineLatestStream.combine2(
        addPost.fetchCommanPosts(),
        addPost.fetchTravelPosts(),
            (List<Map<String, dynamic>> commonPosts,
            List<Map<String, dynamic>> travelPosts) =>
        [commonPosts, travelPosts],
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmerPost();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData ||
            (snapshot.data![0].isEmpty && snapshot.data![1].isEmpty)) {
          return const Center(child: Text('No posts available'));
        }

        List<Map<String, dynamic>> commonPosts = snapshot.data![0];
        List<Map<String, dynamic>> travelPosts = snapshot.data![1];
        List<Map<String, dynamic>> allPosts = [...commonPosts, ...travelPosts];

        allPosts.sort((a, b) {
          DateTime timeA = (a['createdAt'] as Timestamp).toDate();
          DateTime timeB = (b['createdAt'] as Timestamp).toDate();
          return timeB.compareTo(timeA);
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allPosts.length,
          itemBuilder: (context, index) {
            final postData = allPosts[index];
            if (postData.containsKey('destinations')) {
              return GroupExplorerPostCard(
                destination: postData['destinations'][0],
                budget: double.tryParse(postData['budget'] ?? '0') ?? 0.0,
                duration: int.tryParse(postData['duration'] ?? '0') ?? 0,
                travelers:
                int.tryParse(postData['travelersCount'] ?? '0') ?? 0,
              );
            } else {
              return FutureBuilder<Widget>(
                future: PostCard(context, postData),
                builder: (context, postSnapshot) {
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return buildShimmerPost();
                  }
                  if (postSnapshot.hasError) {
                    return const Center(child: Text('Error loading post'));
                  }
                  return postSnapshot.data ?? const SizedBox.shrink();
                },
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // AnimatedSwitcher can be used to animate changes if desired.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: Container(
                key: const ValueKey('places_content'),
                child: buildPlaceCards(),
              ),
            ),
             Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Posts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: textColor(context))),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: Container(
                key: const ValueKey('posts_section'),
                child: buildPostsSection(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
