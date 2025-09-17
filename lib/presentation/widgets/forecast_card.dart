// lib/presentation/widgets/forecast_card.dart
import 'package:flutter/material.dart';
import 'package:weather_app/core/utils/date_utils.dart';
import 'package:weather_app/data/models/weather_model.dart';

class ForecastCard extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const ForecastCard({Key? key, required this.forecasts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5-Day Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: forecasts.length,
              itemBuilder: (context, index) {
                final forecast = forecasts[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppDateUtils.formatWeekday(forecast.date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _getWeatherIcon(forecast.iconCode),
                      const SizedBox(height: 8),
                      Text(
                        '${forecast.maxTemp.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${forecast.minTemp.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getWeatherIcon(String iconCode) {
    IconData icon;
    Color color;
    
    switch (iconCode.substring(0, 2)) {
      case '01':
        icon = Icons.wb_sunny;
        color = Colors.yellow;
        break;
      case '02':
      case '03':
      case '04':
        icon = Icons.cloud;
        color = Colors.grey;
        break;
      case '09':
      case '10':
        icon = Icons.grain;
        color = Colors.blue;
        break;
      case '11':
        icon = Icons.flash_on;
        color = Colors.amber;
        break;
      case '13':
        icon = Icons.ac_unit;
        color = Colors.cyan;
        break;
      case '50':
        icon = Icons.cloud;
        color = Colors.blueGrey;
        break;
      default:
        icon = Icons.wb_sunny;
        color = Colors.yellow;
    }
    
    return Icon(icon, color: color, size: 32);
  }
}