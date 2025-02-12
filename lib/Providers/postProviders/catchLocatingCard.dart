import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../components/exploreComponents/suggestion.dart';
import '../../components/postComponents/locationBottomSheet.dart';

class CachedDestinationCard extends StatefulWidget {
  final String name;
  final double latitude;
  final double longitude;
  final int rate;
  final String categories;

  const CachedDestinationCard({
    Key? key,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.rate,
    required this.categories,
  }) : super(key: key);

  @override
  _CachedDestinationCardState createState() => _CachedDestinationCardState();
}

class _CachedDestinationCardState extends State<CachedDestinationCard> {
  Future<Map<String, String>?>? _locationDetailsFuture;

  @override
  void initState() {
    super.initState();
    _locationDetailsFuture = getLocationDetails(widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>?>(
      future: _locationDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmerCard(); // Or a more localized shimmer for this card.
        } else if (snapshot.hasData) {
          final locationDetails = snapshot.data!;
          return DestinationCard(
            name: widget.name,
            localty: locationDetails['locality'] ?? 'Unknown locality',
            Country: locationDetails['country'] ?? 'Unknown country',
            rate: widget.rate,
            categories: widget.categories,
            latitude: widget.latitude,
            longitude: widget.longitude,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
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
}
