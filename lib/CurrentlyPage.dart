// lib/CurrentlyPage.dart
import 'package:flutter/material.dart';
import 'weather_service.dart';

class CurrentlyPage extends StatelessWidget {
  final WeatherData? weather;
  const CurrentlyPage({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return const Center(child: Text("No weather data yet"));
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${weather!.city}, ${weather!.region.isNotEmpty ? '${weather!.region}, ' : ''}${weather!.country}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "${weather!.temperature} °C",
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            weather!.description,
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            "Wind: ${weather!.windSpeed} km/h",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
