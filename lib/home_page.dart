import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'weather_service.dart';
import 'geocoding_service.dart';
import 'city_suggestion.dart';
import 'CurrentlyPage.dart';
import 'TodayPage.dart';
import 'WeeklyPage.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String locationInput = "";
  List<Map<String, dynamic>> suggestions = [];
  WeatherData? weatherData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchLocation() async {
    setState(() {
      errorMessage = null;
      suggestions = [];
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      setState(() => errorMessage = "Location permissions are denied.");
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => errorMessage =
          "Location permissions are permanently denied. Enable them in settings.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      await fetchWeatherForCoordinates(
        position.latitude,
        position.longitude,
        "Current Location",
      );
    } catch (e) {
      setState(() => errorMessage = "Failed to get location: $e");
    }
  }

  Future<void> updateSuggestions(String query) async {
    final result = await GeocodingService.fetchCitySuggestions(query);
    setState(() => suggestions = result);
  }

  Future<void> fetchWeatherForCoordinates(
      double lat, double lon, String city) async {
    setState(() => errorMessage = null);
    final weather = await WeatherService.fetchWeather(
      latitude: lat,
      longitude: lon,
      city: city,
      region: "",
      country: "",
    );
    if (weather != null) {
      setState(() => weatherData = weather);
    } else {
      setState(() => errorMessage = "Failed to fetch weather data.");
    }
  }

  Future<void> fetchWeatherForCity(Map<String, dynamic> city) async {
    setState(() {
      locationInput = city['name'];
      suggestions = [];
      errorMessage = null;
    });

    final weather = await WeatherService.fetchWeather(
      latitude: city['latitude'],
      longitude: city['longitude'],
      city: city['name'],
      region: city['admin1'] ?? '',
      country: city['country'] ?? '',
    );

    if (weather != null) {
      setState(() => weatherData = weather);
    } else {
      setState(() => errorMessage = "Failed to fetch weather data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (errorMessage != null) {
      bodyContent = Center(child: Text(errorMessage!));
    } else if (weatherData == null) {
      bodyContent = const Center(child: Text("No weather data yet"));
    } else {
      bodyContent = TabBarView(
        controller: _tabController,
        children: [
          CurrentlyPage(weather: weatherData),
          TodayPage(weather: weatherData),
          WeeklyPage(weather: weatherData),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        titleSpacing: 10,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() => locationInput = value);
                  updateSuggestions(value);
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  hintText: "Search city...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.white),
              onPressed: fetchLocation,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          CitySuggestionList(
            suggestions: suggestions,
            onCitySelected: fetchWeatherForCity,
          ),
          Expanded(child: bodyContent),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey[900],
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.wb_sunny), text: "Currently"),
            Tab(icon: Icon(Icons.today), text: "Today"),
            Tab(icon: Icon(Icons.calendar_view_week), text: "Weekly"),
          ],
        ),
      ),
    );
  }
}
