import 'dart:convert';
import 'package:http/http.dart' as http;

/// WEATHER DATA CLASSES
class WeatherData {
  final String city;
  final String region;
  final String country;
  final double temperature;
  final String description;
  final double windSpeed;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  WeatherData({
    required this.city,
    required this.region,
    required this.country,
    required this.temperature,
    required this.description,
    required this.windSpeed,
    required this.hourly,
    required this.daily,
  });
}

class HourlyWeather {
  final String time;
  final double temperature;
  final String description;
  final double windSpeed;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.description,
    required this.windSpeed,
  });
}

class DailyWeather {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String description;

  DailyWeather({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
  });
}

/// WEATHER SERVICE
class WeatherService {
  static Future<WeatherData?> fetchWeather({
    required double latitude,
    required double longitude,
    required String city,
    required String region,
    required String country,
  }) async {
    try {
      final url =
          "https://api.open-meteo.com/v1/forecast"
          "?latitude=$latitude&longitude=$longitude"
          "&current_weather=true"
          "&hourly=temperature_2m,weathercode,windspeed_10m"
          "&daily=temperature_2m_max,temperature_2m_min,weathercode"
          "&timezone=auto";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);

      final current = data['current_weather'];
      final temperature = (current['temperature'] as num).toDouble();
      final windSpeed = (current['windspeed'] as num).toDouble();
      final description = _mapWeatherCode(current['weathercode']);

      // Hourly
      final hourlyTemps = data['hourly']['temperature_2m'] as List;
      final hourlyCodes = data['hourly']['weathercode'] as List;
      final hourlyWinds = data['hourly']['windspeed_10m'] as List;
      final hourlyTimes = data['hourly']['time'] as List;

      List<HourlyWeather> hourly = [];
      for (int i = 0; i < hourlyTemps.length; i++) {
        hourly.add(HourlyWeather(
time: hourlyTimes[i].toString(), // keep full ISO date string
          temperature: (hourlyTemps[i] as num).toDouble(),
          windSpeed: (hourlyWinds[i] as num).toDouble(),
          description: _mapWeatherCode(hourlyCodes[i]),
        ));
      }

      // Daily
      final dailyMax = data['daily']['temperature_2m_max'] as List;
      final dailyMin = data['daily']['temperature_2m_min'] as List;
      final dailyCodes = data['daily']['weathercode'] as List;
      final dailyDates = data['daily']['time'] as List;

      List<DailyWeather> daily = [];
      for (int i = 0; i < dailyMax.length; i++) {
        daily.add(DailyWeather(
          date: dailyDates[i],
          minTemp: (dailyMin[i] as num).toDouble(),
          maxTemp: (dailyMax[i] as num).toDouble(),
          description: _mapWeatherCode(dailyCodes[i]),
        ));
      }

      return WeatherData(
        city: city,
        region: region,
        country: country,
        temperature: temperature,
        windSpeed: windSpeed,
        description: description,
        hourly: hourly,
        daily: daily,
      );
    } catch (e) {
      print("WeatherService error: $e");
      return null;
    }
  }

  static String _mapWeatherCode(dynamic code) {
    switch (code) {
      case 0:
        return "Clear sky";
      case 1:
      case 2:
      case 3:
        return "Partly cloudy";
      case 45:
      case 48:
        return "Fog";
      case 51:
      case 53:
      case 55:
        return "Drizzle";
      case 61:
      case 63:
      case 65:
        return "Rain";
      case 66:
      case 67:
        return "Freezing rain";
      case 71:
      case 73:
      case 75:
        return "Snow";
      case 77:
        return "Snow grains";
      case 80:
      case 81:
      case 82:
        return "Rain showers";
      case 85:
      case 86:
        return "Snow showers";
      case 95:
      case 96:
      case 99:
        return "Thunderstorm";
      default:
        return "Unknown";
    }
  }
}
