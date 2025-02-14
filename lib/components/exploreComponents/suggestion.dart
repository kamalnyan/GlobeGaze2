import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globegaze/components/isDarkMode.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';

import '../../themes/colors.dart';

class DestinationCard extends StatelessWidget {
  final String name;
  final String localty;
  final String Country;
  final int rate;
  final String categories;
  final double latitude;
  final double longitude;

  const DestinationCard({
    Key? key,
    required this.name,
    required this.localty,
    required this.Country,
    required this.rate,
    required this.categories,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  void _launchMap() async {
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchMap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Adjusted margin
        padding: const EdgeInsets.fromLTRB(17, 17, 17, 8), // Reduced bottom padding
        decoration: BoxDecoration(
          color: isDarkMode(context)?primaryDarkBlue:neutralLightGrey.withValues(alpha: 0.6),
          // gradient: LinearGradient(
          //   colors: [
          //     neutralLightGrey.withValues(alpha: 0.5),
          //     Colors.white.withValues(alpha:0.7),
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          // ),
          borderRadius: BorderRadius.circular(20),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withValues(alpha:0.1),
          //     blurRadius: 20,
          //     offset: const Offset(0, 10),
          //   ),
          // ],
          border: Border.all(color: Colors.white.withValues(alpha:0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style:  TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    rate,
                        (index) => const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 📍 Location & Country
            Row(
              children: [
                const Icon(CupertinoIcons.location_solid,
                    size: 18, color: Colors.redAccent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$localty, $Country',
                    style:  TextStyle(
                      fontSize: 14,
                      color: hintColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Slightly reduced spacing
            // 🏷️ Categories
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Reduced vertical padding
              decoration: BoxDecoration(
                color: hintColor(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                categories.split(',')[0],
                style:  TextStyle(
                  fontSize: 14,
                  color: textColor(context),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

            const SizedBox(height: 10), // Adjusted spacing

            // 🚗 Get Directions Button (Half-width)
            Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: 0.5, // 50% of the parent width
                child: ElevatedButton.icon(
                  onPressed: _launchMap,
                  icon: const Icon(
                    CupertinoIcons.arrow_turn_up_right,
                    color: Colors.white,
                    size: 12,
                  ),
                  label: const Text(
                    'Directions',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.85),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 10), // Reduced vertical padding
                    elevation: 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerCardScroller extends StatefulWidget {
  const ShimmerCardScroller({Key? key}) : super(key: key);

  @override
  _ShimmerCardScrollerState createState() => _ShimmerCardScrollerState();
}

class _ShimmerCardScrollerState extends State<ShimmerCardScroller> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);

    // Auto-scroll every 3 seconds
    _scrollTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < 4) { // Adjust based on item count
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220, // Set fixed height for cards
      child: PageView.builder(
        controller: _pageController,
        itemCount: 5, // Number of shimmer items
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Destination Name (Shimmer)
                    Container(
                      width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location Row (Shimmer)
                    Row(
                      children: [
                        Icon(CupertinoIcons.location_solid,
                            size: 18, color: Colors.grey[400]),
                        const SizedBox(width: 6),
                        Container(
                          width: 100,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Category Tag (Shimmer)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        width: 60,
                        height: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Directions Button (Shimmer)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 100,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NonScrollableShimmerCard extends StatelessWidget {
  const NonScrollableShimmerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230, // Set a fixed height for the card
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Destination Name (Shimmer)
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Location Row (Shimmer)
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.location_solid,
                      size: 18,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Category Tag (Shimmer)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 60,
                    height: 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 10),
                // Directions Button (Shimmer)
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 100,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

