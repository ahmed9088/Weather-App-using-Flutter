// lib/core/routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:weather_app/presentation/screens/details_screen.dart';
import 'package:weather_app/presentation/screens/home_screen.dart';
import 'package:weather_app/presentation/screens/search_screen.dart';
import 'package:weather_app/presentation/screens/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String details = '/details';
  static const String search = '/search';
  static const String settings = '/settings';
  
  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    details: (context) => const DetailsScreen(),
    search: (context) => const SearchScreen(),
    settings: (context) => const SettingsScreen(),
  };
}