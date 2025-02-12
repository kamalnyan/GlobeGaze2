import '../../components/postComponents/locationBottomSheet.dart';

class LocationDetailsCache {
  static final LocationDetailsCache _instance = LocationDetailsCache._internal();
  factory LocationDetailsCache() => _instance;
  LocationDetailsCache._internal();

  final Map<String, Future<Map<String, String>?>> cache = {};
  Future<Map<String, String>?> getCachedLocationDetails(double lat, double lon) {
    final key = '$lat,$lon';
    if (!cache.containsKey(key)) {
      cache[key] = getLocationDetails(lat, lon);
    }
    return cache[key]!;
  }
}
