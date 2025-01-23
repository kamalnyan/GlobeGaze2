import 'package:flutter/foundation.dart';

class LocationProvider with ChangeNotifier {
  String? _selectedLocation;

  String? get selectedLocation => _selectedLocation;

  void setSelectedLocation(String? userSelectedLocation) {
    _selectedLocation = userSelectedLocation;
    notifyListeners();
  }
}
