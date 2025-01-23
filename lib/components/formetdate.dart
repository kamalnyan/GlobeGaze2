import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
String formatTimestamp(dynamic timestamp, BuildContext context) {
  DateTime dateTime;
  if (timestamp is DateTime) {
    dateTime = timestamp;
  } else if (timestamp is int) {
    // Assuming timestamp is in seconds, convert it
    dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  } else if (timestamp is Timestamp) {
    dateTime = timestamp.toDate();
  } else {
    return 'Unknown Time';
  }
  final formattedTime = DateFormat('hh:mm a', 'en_US').format(dateTime);
  return formattedTime;

}
String formatDateTime(DateTime dateTime) {
return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
}

