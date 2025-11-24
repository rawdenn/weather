// lib/WeeklyPage.dart
import 'package:flutter/material.dart';
import 'weather_service.dart';

class WeeklyPage extends StatelessWidget {
  final WeatherData? weather;
  const WeeklyPage({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather == null) {
      return const Center(child: Text("No weather data yet"));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "${weather!.city}, ${weather!.region.isNotEmpty ? '${weather!.region}, ' : ''}${weather!.country}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: weather!.daily.length,
            itemBuilder: (context, index) {
              final day = weather!.daily[index];
              return ListTile(
                leading: Text(day.date),
                title: Text("Min: ${day.minTemp} °C, Max: ${day.maxTemp} °C"),
                subtitle: Text(day.description),
              );
            },
          ),
        ),
      ],
    );
  }
}
