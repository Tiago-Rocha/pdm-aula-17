import 'package:flutter/material.dart';

enum WeatherType {
  sunny('Sol', Icons.wb_sunny),
  partlyCloudy('Parcialmente nublado', Icons.cloud_queue),
  cloudy('Nublado', Icons.cloud),
  rain('Chuva', Icons.umbrella),
  storm('Trovoada', Icons.thunderstorm);

  const WeatherType(this.description, this.icon);

  final String description;
  final IconData icon;
}

class DayForecast {
  const DayForecast({
    required this.date,
    required this.type,
    required this.tMin,
    required this.tMax,
    required this.rainChance,
    required this.windClass,
  });

  final DateTime date;
  final WeatherType type;
  final double tMin;
  final double tMax;
  final int rainChance; // 0 to 100
  final int windClass; // 1 weak to 4 very strong

  factory DayForecast.fromJson(Map<String, dynamic> json) {
    final weather = json['weatherType'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    return DayForecast(
      date: DateTime.parse(json['date'] as String),
      type: WeatherType.values.byName(weather['category'] as String),
      tMin: (json['tMin'] as num).toDouble(),
      tMax: (json['tMax'] as num).toDouble(),
      rainChance: json['rainChance'] as int,
      windClass: wind['class'] as int,
    );
  }
}

class Forecast {
  const Forecast({required this.location, required this.days});

  final String location;
  final List<DayForecast> days;

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final days = json['days'] as List<dynamic>;
    return Forecast(
      location: json['location'] as String,
      days: days
          .map((day) => DayForecast.fromJson(day as Map<String, dynamic>))
          .toList(),
    );
  }
}
