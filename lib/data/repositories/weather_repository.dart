// lib/data/repositories/weather_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/data/models/weather_model.dart';

class WeatherRepository {
  Future<WeatherModel> getWeatherByCity(String city) async {
    final response = await http.get(Uri.parse(
      '${AppConstants.baseUrl}/weather?q=$city&appid=${AppConstants.apiKey}&units=metric',
    )).timeout(AppConstants.apiTimeout);

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.body}');
    }
  }

  Future<WeatherModel> getWeatherByLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable location services.');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied. Please enable location permissions.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable them in app settings.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Make API request with lat and lon parameters
      final response = await http.get(Uri.parse(
        '${AppConstants.baseUrl}/weather?lat=${position.latitude}&lon=${position.longitude}&appid=${AppConstants.apiKey}&units=metric',
      )).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load weather data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting location: $e');
    }
  }

  Future<List<DailyForecast>> getForecastByCity(String city) async {
    final response = await http.get(Uri.parse(
      '${AppConstants.baseUrl}/forecast?q=$city&appid=${AppConstants.apiKey}&units=metric',
    )).timeout(AppConstants.apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['list'];
      
      // Process the forecast data to get daily forecasts
      Map<String, DailyForecast> dailyMap = {};
      
      for (var item in list) {
        final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final dateStr = '${date.year}-${date.month}-${date.day}';
        
        if (!dailyMap.containsKey(dateStr)) {
          dailyMap[dateStr] = DailyForecast.fromJson({
            'dt': item['dt'],
            'temp': {
              'min': item['main']['temp_min'],
              'max': item['main']['temp_max'],
            },
            'weather': [item['weather'][0]],
          });
        } else {
          // Update min and max temperatures
          final existing = dailyMap[dateStr]!;
          final minTemp = item['main']['temp_min'];
          final maxTemp = item['main']['temp_max'];
          
          if (minTemp < existing.minTemp) {
            dailyMap[dateStr] = DailyForecast(
              date: existing.date,
              minTemp: minTemp,
              maxTemp: existing.maxTemp,
              condition: existing.condition,
              iconCode: existing.iconCode,
            );
          }
          
          if (maxTemp > existing.maxTemp) {
            dailyMap[dateStr] = DailyForecast(
              date: existing.date,
              minTemp: existing.minTemp,
              maxTemp: maxTemp,
              condition: existing.condition,
              iconCode: existing.iconCode,
            );
          }
        }
      }
      
      // Convert map to list and take only the next 5 days
      final List<DailyForecast> forecasts = dailyMap.values.toList();
      forecasts.sort((a, b) => a.date.compareTo(b.date));
      
      // Skip today and take next 5 days
      final today = DateTime.now();
      final filtered = forecasts.where((f) => 
        f.date.day != today.day || f.date.month != today.month || f.date.year != today.year
      ).take(5).toList();
      
      return filtered;
    } else {
      throw Exception('Failed to load forecast data: ${response.body}');
    }
  }

  Future<List<DailyForecast>> getForecastByLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable location services.');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied. Please enable location permissions.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable them in app settings.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Make API request with lat and lon parameters
      final response = await http.get(Uri.parse(
        '${AppConstants.baseUrl}/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=${AppConstants.apiKey}&units=metric',
      )).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['list'];
        
        // Process the forecast data to get daily forecasts
        Map<String, DailyForecast> dailyMap = {};
        
        for (var item in list) {
          final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dateStr = '${date.year}-${date.month}-${date.day}';
          
          if (!dailyMap.containsKey(dateStr)) {
            dailyMap[dateStr] = DailyForecast.fromJson({
              'dt': item['dt'],
              'temp': {
                'min': item['main']['temp_min'],
                'max': item['main']['temp_max'],
              },
              'weather': [item['weather'][0]],
            });
          } else {
            // Update min and max temperatures
            final existing = dailyMap[dateStr]!;
            final minTemp = item['main']['temp_min'];
            final maxTemp = item['main']['temp_max'];
            
            if (minTemp < existing.minTemp) {
              dailyMap[dateStr] = DailyForecast(
                date: existing.date,
                minTemp: minTemp,
                maxTemp: existing.maxTemp,
                condition: existing.condition,
                iconCode: existing.iconCode,
              );
            }
            
            if (maxTemp > existing.maxTemp) {
              dailyMap[dateStr] = DailyForecast(
                date: existing.date,
                minTemp: existing.minTemp,
                maxTemp: maxTemp,
                condition: existing.condition,
                iconCode: existing.iconCode,
              );
            }
          }
        }
        
        // Convert map to list and take only the next 5 days
        final List<DailyForecast> forecasts = dailyMap.values.toList();
        forecasts.sort((a, b) => a.date.compareTo(b.date));
        
        // Skip today and take next 5 days
        final today = DateTime.now();
        final filtered = forecasts.where((f) => 
          f.date.day != today.day || f.date.month != today.month || f.date.year != today.year
        ).take(5).toList();
        
        return filtered;
      } else {
        throw Exception('Failed to load forecast data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting location forecast: $e');
    }
  }
}