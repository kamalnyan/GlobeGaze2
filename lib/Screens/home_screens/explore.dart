import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../apis/addPost.dart';
import '../../apis/datamodel.dart';
import '../../components/exploreComponents/suggestion.dart';
import '../../components/postComponents/group_explorer_postcard.dart';
import '../../components/postComponents/locationBottomSheet.dart';
import '../../components/postComponents/new_post.dart';
import '../../components/shimmarEffect.dart';
import '../../locationservices/locationForSUGGESATION.dart';
import '../../themes/colors.dart';
import '../../Providers/postProviders/exploreGetx.dart';

class Explore extends StatefulWidget {
  const Explore({Key? key}) : super(key: key);
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final ExploreController exploreController = Get.put(ExploreController());
  final RefreshController _refreshController = RefreshController();
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _setupScrollController();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        exploreController.loadMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      await exploreController.refreshData();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  Widget buildPlaceCards() {
    return Obx(() {
      if (exploreController.isLoading.value) {
        return const ShimmerCardScroller();
      }
      if (exploreController.places.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 48, color: hintColor(context)),
              const SizedBox(height: 16),
              Text(
                'No places available',
                style: TextStyle(
                  fontSize: 18,
                  color: hintColor(context),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => exploreController.refreshData(),
                child: const Text('Refresh'),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        height: 210,
        child: PageView.builder(
          controller: _pageController,
          itemCount: exploreController.places.length,
          itemBuilder: (context, index) {
            var place = exploreController.places[index];
            return _buildPlaceCard(place);
          },
        ),
      );
    });
  }

  Widget _buildPlaceCard(dynamic place) {
    String name = place['properties']['name'] ?? 'Unknown';
    double longitude = place['geometry']['coordinates'][0];
    double latitude = place['geometry']['coordinates'][1];
    int rate = place['properties']['rate'] ?? 0;
    String categories = place['properties']['kinds'] ?? '';

    return FutureBuilder<Map<String, String>?>(
      future: getLocationDetails(latitude, longitude),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const NonScrollableShimmerCard();
        }
        
        if (snapshot.hasError) {
          return _buildErrorCard();
        }

        if (!snapshot.hasData) {
          return _buildEmptyCard();
        }

        Map<String, String> locationDetails = snapshot.data!;
        return DestinationCard(
          name: name,
          localty: locationDetails['locality'] ?? 'Unknown locality',
          Country: locationDetails['country'] ?? 'Unknown country',
          rate: rate,
          categories: categories,
          latitude: latitude,
          longitude: longitude,
        );
      },
    );
  }

  Widget _buildErrorCard() {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 8),
            Text(
              'Failed to load location details',
              style: TextStyle(color: hintColor(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Card(
      child: Center(
        child: Text(
          'No location details available',
          style: TextStyle(color: hintColor(context)),
        ),
      ),
    );
  }

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
          return _buildErrorWidget(snapshot.error);
        }

        if (!snapshot.hasData ||
            (snapshot.data![0].isEmpty && snapshot.data![1].isEmpty)) {
          return _buildEmptyPostsWidget();
        }

        return _buildPostsList(snapshot.data!);
      },
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading posts',
            style: TextStyle(
              fontSize: 18,
              color: hintColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: hintColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPostsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 48, color: hintColor(context)),
          const SizedBox(height: 16),
          Text(
            'No posts available',
            style: TextStyle(
              fontSize: 18,
              color: hintColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<List<Map<String, dynamic>>> data) {
    List<Map<String, dynamic>> commonPosts = data[0];
    List<Map<String, dynamic>> travelPosts = data[1];
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
        return _buildPostCard(postData);
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> postData) {
    if (postData.containsKey('destinations')) {
      return _buildGroupExplorerPostCard(postData);
    } else {
      return FutureBuilder<Widget>(
        future: PostCard(context, postData),
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return buildShimmerPost();
          }
          if (postSnapshot.hasError) {
            return _buildErrorWidget(postSnapshot.error);
          }
          return postSnapshot.data ?? const SizedBox.shrink();
        },
      );
    }
  }

  Widget _buildGroupExplorerPostCard(Map<String, dynamic> postData) {
    final String? creatorId = postData['createdBy'] as String?;
    final String postId = postData['id'] ?? '';

    if (creatorId == null || creatorId.isEmpty) {
      return _buildDefaultGroupExplorerPostCard(postData, postId);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(creatorId)
          .get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        String creatorName = 'Unknown User';
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          creatorName = userData?['FullName']?.toString() ?? 'Unknown User';
        }

        return GroupExplorerPostCard(
          genderPreference: postData['genderPreference'] ?? '',
          time: postData['createdAt'],
          destination: postData['destinations'][0],
          budget: double.tryParse(postData['budget']?.toString() ?? '0') ?? 0.0,
          duration: int.tryParse(postData['duration']?.toString() ?? '0') ?? 0,
          travelers: int.tryParse(postData['travelersCount']?.toString() ?? '0') ?? 0,
          createdBy: creatorId,
          creatorName: creatorName,
          itinerary: postData['itinerary'] ?? '',
          preferredAge: postData['preferredAge'] ?? '',
          accommodation: postData['accommodation'] ?? '',
          transportation: postData['transportation'] ?? '',
          organizerName: postData['organizerName'] ?? '',
          contactInfo: postData['contactInfo'] ?? '',
          socialMediaHandle: postData['socialMediaHandle'] ?? '',
          travelInterests: postData['travelInterests'] ?? '',
          experienceLevel: postData['experienceLevel'] ?? '',
          emergencyContact: postData['emergencyContact'] ?? '',
          healthRestrictions: postData['healthRestrictions'] ?? '',
          postId: postId,
        );
      },
    );
  }

  Widget _buildDefaultGroupExplorerPostCard(Map<String, dynamic> postData, String postId) {
    return GroupExplorerPostCard(
      genderPreference: postData['genderPreference'] ?? '',
      time: postData['createdAt'],
      destination: postData['destinations'][0],
      budget: double.tryParse(postData['budget']?.toString() ?? '0') ?? 0.0,
      duration: int.tryParse(postData['duration']?.toString() ?? '0') ?? 0,
      travelers: int.tryParse(postData['travelersCount']?.toString() ?? '0') ?? 0,
      createdBy: '',
      creatorName: 'Unknown User',
      itinerary: postData['itinerary'] ?? '',
      preferredAge: postData['preferredAge'] ?? '',
      accommodation: postData['accommodation'] ?? '',
      transportation: postData['transportation'] ?? '',
      organizerName: postData['organizerName'] ?? '',
      contactInfo: postData['contactInfo'] ?? '',
      socialMediaHandle: postData['socialMediaHandle'] ?? '',
      travelInterests: postData['travelInterests'] ?? '',
      experienceLevel: postData['experienceLevel'] ?? '',
      emergencyContact: postData['emergencyContact'] ?? '',
      healthRestrictions: postData['healthRestrictions'] ?? '',
      postId: postId,
    );
  }

  Widget buildShimmerPost() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget(width: double.infinity, height: 200),
          const SizedBox(height: 10),
          ShimmerWidget(width: 150, height: 20),
          const SizedBox(height: 10),
          ShimmerWidget(width: double.infinity, height: 200),
          const SizedBox(height: 10),
          ShimmerWidget(width: 150, height: 20),
          const SizedBox(height: 10),
          ShimmerWidget(width: double.infinity, height: 200),
          const SizedBox(height: 10),
          ShimmerWidget(width: 150, height: 20),
          const SizedBox(height: 10),
          ShimmerWidget(width: double.infinity, height: 200),
          const SizedBox(height: 10),
          ShimmerWidget(width: 150, height: 20),
          const SizedBox(height: 10),
          ShimmerWidget(width: double.infinity, height: 200),
          const SizedBox(height: 10),
          ShimmerWidget(width: 150, height: 20),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: const WaterDropHeader(),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Posts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor(context),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: Container(
                    key: const ValueKey('posts_section'),
                    child: buildPostsSection(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
