import 'package:flutter/material.dart';
import 'package:globegaze/themes/colors.dart';

Widget travelCard({
  required String destination,
  required double budget,
  required int duration,
  required int travelers,
}) {
  return SizedBox(
    height: 250,
    child: Card(
      color: Color(0xff3b3b3b),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  destination,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.location_on, color: PrimaryColor),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTile(Icons.attach_money, 'Budget', '\$${budget.toStringAsFixed(2)}'),
                _buildInfoTile(Icons.calendar_today, 'Duration', '$duration Days'),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTile(Icons.group, 'Travelers', '$travelers People'),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInfoTile(IconData icon, String label, String value) {
  return Row(
    children: [
      Icon(icon, color: PrimaryColor),
      SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    ],
  );
}
