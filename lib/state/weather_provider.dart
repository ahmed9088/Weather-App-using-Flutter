// lib/state/weather_provider.dart
import 'package:flutter/material.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherRepository _repository = WeatherRepository();
  
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  List<DailyForecast> _forecast = [];
  bool _isLoadingForecast = false;
  
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  List<DailyForecast> get forecast => _forecast;
  bool get isLoadingForecast => _isLoadingForecast;

  Future<void> fetchWeatherByCity(String city) async {
    _setLoading(true);
    try {
      _weather = await _repository.getWeatherByCity(city);
      _errorMessage = null;
      _lastUpdated = DateTime.now();
      
      // Also fetch forecast
      await _fetchForecastByCity(city);
    } catch (e) {
      _errorMessage = e.toString();
      _lastUpdated = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchWeatherByLocation() async {
    _setLoading(true);
    try {
      _weather = await _repository.getWeatherByLocation();
      _errorMessage = null;
      _lastUpdated = DateTime.now();
      
      // Also fetch forecast
      await _fetchForecastByLocation();
    } catch (e) {
      _errorMessage = e.toString();
      _lastUpdated = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchForecastByCity(String city) async {
    _setLoadingForecast(true);
    try {
      _forecast = await _repository.getForecastByCity(city);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoadingForecast(false);
    }
  }

  Future<void> _fetchForecastByLocation() async {
    _setLoadingForecast(true);
    try {
      _forecast = await _repository.getForecastByLocation();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoadingForecast(false);
    }
  }

  Future<void> refreshForecast() async {
    if (_weather != null) {
      if (_weather!.cityName.isNotEmpty) {
        await _fetchForecastByCity(_weather!.cityName);
      } else {
        await _fetchForecastByLocation();
      }
    }
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingForecast(bool loading) {
    _isLoadingForecast = loading;
    notifyListeners();
  }
}