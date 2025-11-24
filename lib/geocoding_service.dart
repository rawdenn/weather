// lib/services/geocoding_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static Future<List<Map<String, dynamic>>> fetchCitySuggestions(
      String query) async {
    if (query.isEmpty) return [];

    final url =
        "https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5&language=en&format=json";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final data = json.decode(response.body);

    if (data["results"] == null) return [];

    return List<Map<String, dynamic>>.from(data["results"]);
  }
}
