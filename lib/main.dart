import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/presentation/screens/home_screen.dart';
import 'package:weather_app/routes/app_routes.dart';
import 'package:weather_app/state/theme_provider.dart';
import 'package:weather_app/state/weather_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Weather App',
            theme: ThemeData.light().copyWith(
              primaryColor: Colors.blue,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.blue,
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.grey[800],
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
            initialRoute: AppRoutes.home,
            routes: AppRoutes.routes,
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}