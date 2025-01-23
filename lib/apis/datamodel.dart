import 'dart:convert';
import 'package:http/http.dart' as http;
class PlaceService {
  static const String apiUrl = 'https://opentripmap-places-v1.p.rapidapi.com/en/places/bbox';
  static const Map<String, String> headers = {
    'Accept': 'application/json',
    'x-rapidapi-key': '87522ac81amsh22b0701743c7ef0p149077jsn47a52de75e81',
    'x-rapidapi-host': 'opentripmap-places-v1.p.rapidapi.com',
  };
  Future<List<dynamic>> fetchPlaces(double lonMin, double latMin, double lonMax, double latMax) async {
    final url = Uri.parse(
      '$apiUrl?lon_min=$lonMin&lat_min=$latMin&lon_max=$lonMax&lat_max=$latMax',
    );
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['features'];
    } else {
      print('Failed to load places, status code: ${response.statusCode}');
      throw Exception('Failed to load places');
    }
  }
}
