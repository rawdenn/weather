import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

bool err = false;
String result = "";
bool afterNoon = false;
bool isLoading = false;
List<dynamic> suggestions = [];
TextEditingController search = TextEditingController();

String getSafe(List list, int index, [String fallback = ""]) {
  return (index < list.length) ? list[index].trim() : fallback;
}

final Map<int, String> weatherDescriptions = {
  0: "Clear sky",
  1: "Mainly clear",
  2: "Partly cloudy",
  3: "Overcast",
  45: "Fog",
  48: "Depositing rime fog",
  51: "Light drizzle",
  53: "Moderate drizzle",
  55: "Dense drizzle",
  61: "Light rain",
  63: "Moderate rain",
  65: "Heavy rain",
  71: "Snowfall",
  73: "Moderate snowfall",
  75: "Heavy snowfall",
  95: "Thunderstorm",
  96: "Thunderstorm with slight hail",
  99: "Thunderstorm with heavy hail",
};

class API {
  static Future<Map<String, dynamic>?> getWeekly(double lat, double lon) async {
    final url =
        "https://api.open-meteo.com/v1/forecast"
        "?latitude=$lat&longitude=$lon"
        "&daily=weathercode,temperature_2m_max,temperature_2m_min"
        "&timezone=auto";

    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<Map<String, dynamic>?> getHourly(double lat, double lon) async {
    final url =
        "https://api.open-meteo.com/v1/forecast"
        "?latitude=$lat&longitude=$lon"
        "&hourly=temperature_2m,weathercode,windspeed_10m";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return null;
  }

  static Future searchCities(String query) async {
    err = false;
    final api =
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5";
    final res = await http.get(Uri.parse(api));

    if (res.statusCode == 200) {
      if (json.decode(res.body).length == 0) {
        err = true;
        result = "couldn't find any cities with that name";
      }
      return json.decode(res.body);
    } else {
      err = true;
      result = "connection error failed to connect!";
    }
    return [];
  }

  static Future<dynamic> reverseGeocode(double lat, double lon) async {
    final url =
        "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1";

    final res = await http.get(
      Uri.parse(url),
      headers: {"User-Agent": "Flutter-Weather-App"},
    );

    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  static Future<Map<String, dynamic>?> getWeather(
    double lat,
    double lon,
  ) async {
    try {
      final url =
          "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class LocationService {
  static Future<LocationPermissionResult> checkAndRequestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionResult(
        success: false,
        errorMessage:
            'Location services are disabled. Please enable them in your device settings.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionResult(
          success: false,
          errorMessage:
              'Location permission denied. You can still search for cities manually.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionResult(
        success: false,
        errorMessage:
            'Location permissions are permanently denied. Please enable them in your app settings. You can still search for cities manually.',
      );
    }

    return LocationPermissionResult(success: true);
  }

  /// Get the current position of the device
  static Future<LocationResult> getCurrentPosition() async {
    try {
      final permissionResult = await checkAndRequestPermissions();
      if (!permissionResult.success) {
        return LocationResult(
          success: false,
          errorMessage: permissionResult.errorMessage,
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LocationResult(
        success: true,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      return LocationResult(
        success: false,
        errorMessage: 'Failed to get current location: ${e.toString()}',
      );
    }
  }
}

class LocationPermissionResult {
  final bool success;
  final String? errorMessage;

  LocationPermissionResult({required this.success, this.errorMessage});
}

class LocationResult {
  final bool success;
  final double? latitude;
  final double? longitude;
  final String? errorMessage;

  LocationResult({
    required this.success,
    this.latitude,
    this.longitude,
    this.errorMessage,
  });

  String get coordinates {
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }
    return '';
  }
}
