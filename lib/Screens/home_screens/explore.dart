import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';
import '../../Providers/postProviders/catchLocatingCard.dart';
import '../../Providers/postProviders/providerCatche.dart';
import '../../apis/addPost.dart';
import '../../apis/datamodel.dart';
import '../../components/exploreComponents/postcard.dart';
import '../../components/exploreComponents/suggestion.dart';
import '../../components/postComponents/group_explorer_postcard.dart';
import '../../components/postComponents/locationBottomSheet.dart';
import '../../locationservices/locationForSUGGESATION.dart';
import '../../themes/dark_light_switch.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  bool get wantKeepAlive => true;

  // Your existing fields and methods remain here.
  final ValueNotifier<List<dynamic>> placesNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isLoadingPlacesNotifier = ValueNotifier(true);
  final ValueNotifier<String> locationNotifier = ValueNotifier("Fetching location...");
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
  Widget buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              width: 350,
              height: 200,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 350,
              height: 200,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 350,
              height: 200,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 350,
              height: 200,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 350,
              height: 200,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            const SizedBox(width: 20),
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
                  future:LocationDetailsCache().getCachedLocationDetails(latitude, longitude),
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return buildShimmerCard();
                    } else if (snapshot.hasData) {
                      Map<String, String> locationDetails = snapshot.data!;
                      return CachedDestinationCard(
                        name: name,
                        latitude: latitude,
                        longitude: longitude,
                        rate: rate,
                        categories: categories,
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
                return buildShimmerCard();
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
            List<Map<String, dynamic>> travelPosts) => [commonPosts, travelPosts],
      ),
      builder: (context, snapshot) {
        // Show shimmer until both streams have emitted data.
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

        // Combine and sort posts
        List<Map<String, dynamic>> commonPosts = snapshot.data![0];
        List<Map<String, dynamic>> travelPosts = snapshot.data![1];
        List<Map<String, dynamic>> allPosts = [...commonPosts, ...travelPosts];

        allPosts.sort((a, b) {
          DateTime timeA = (a['createdAt'] as Timestamp).toDate();
          DateTime timeB = (b['createdAt'] as Timestamp).toDate();
          return timeB.compareTo(timeA);
        });

        // For each post, prepare a Future that returns its widget.
        List<Future<Widget>> postFutures = allPosts.map((postData) {
          // If this is a group post, return its widget immediately.
          if (postData.containsKey('destinations')) {
            return Future.value(
              GroupExplorerPostCard(
                destination: postData['destinations'][0],
                budget: double.tryParse(postData['budget'] ?? '0') ?? 0.0,
                duration: int.tryParse(postData['duration'] ?? '0') ?? 0,
                travelers: int.tryParse(postData['travelersCount'] ?? '0') ?? 0,
              ),
            );
          } else {
            // For normal posts, use your asynchronous PostCard function.
            return PostCard(context, postData);
          }
        }).toList();

        // Wait for all the post widgets to be built.
        return FutureBuilder<List<Widget>>(
          future: Future.wait(postFutures),
          builder: (context, postsSnapshot) {
            // Show shimmer until all posts are ready.
            if (postsSnapshot.connectionState == ConnectionState.waiting) {
              return buildShimmerPost();
            }
            if (postsSnapshot.hasError) {
              return Center(child: Text('Error loading posts'));
            }
            List<Widget> postWidgets = postsSnapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: postWidgets.length,
              itemBuilder: (context, index) {
                return postWidgets[index];
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkLight(isDarkMode),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Posts',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
