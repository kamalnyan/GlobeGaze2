import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Reduced bottom padding
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌍 Destination Name & Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
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
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                categories.split(',')[0],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),

            const SizedBox(height: 10), // Adjusted spacing

            // 🚗 Get Directions Button (Half-width)
            Align(
              alignment: Alignment.centerLeft,
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