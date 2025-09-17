// lib/data/models/weather_model.dart
class WeatherModel {
  final String cityName;
  final double temperature;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final DateTime sunrise;
  final DateTime sunset;
  final double? visibility;
  final double pressure;
  final int cloudiness;
  final List<DailyForecast> dailyForecasts;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
    this.visibility,
    required this.pressure,
    required this.cloudiness,
    required this.dailyForecasts,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      visibility: json['visibility']?.toDouble() / 1000, // Convert from meters to km
      pressure: json['main']['pressure'].toDouble(),
      cloudiness: json['clouds']['all'],
      dailyForecasts: [], // Will be populated separately
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String condition;
  final String iconCode;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.iconCode,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: json['temp']['min'].toDouble(),
      maxTemp: json['temp']['max'].toDouble(),
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}