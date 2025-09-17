import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/data/models/weather_model.dart';

class ApiService {
  Future<WeatherModel> fetchWeather(String query) async {
    // Trim the API key to remove any accidental spaces
    final apiKey = AppConstants.apiKey.trim();
    final url = '${AppConstants.baseUrl}/weather?q=$query&appid=$apiKey&units=metric';
    
    print('API Request: $url'); // For debugging
    
    final response = await http.get(Uri.parse(url)).timeout(AppConstants.apiTimeout);
    
    print('API Response status: ${response.statusCode}'); // For debugging
    
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      print('API Error: ${response.body}'); // For debugging
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }
}