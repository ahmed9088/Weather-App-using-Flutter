import 'package:flutter/material.dart';
import 'package:weather_app/core/utils/date_utils.dart';
import 'package:weather_app/data/models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({Key? key, required this.weather}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weather.cityName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              _getWeatherIcon(weather.condition),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${weather.temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            weather.description,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WeatherDetail(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: '${weather.humidity}%',
              ),
              WeatherDetail(
                icon: Icons.air,
                label: 'Wind',
                value: '${weather.windSpeed} m/s',
              ),
              WeatherDetail(
                icon: Icons.compress,
                label: 'Pressure',
                value: '${weather.pressure} hPa',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WeatherDetail(
                icon: Icons.wb_sunny,
                label: 'Sunrise',
                value: _formatTime(weather.sunrise),
              ),
              WeatherDetail(
                icon: Icons.bedtime,
                label: 'Sunset',
                value: _formatTime(weather.sunset),
              ),
              WeatherDetail(
                icon: Icons.cloud,
                label: 'Cloudiness',
                value: '${weather.cloudiness}%',
              ),
            ],
          ),
          if (weather.visibility != null) ...[
            const SizedBox(height: 20),
            WeatherDetail(
              icon: Icons.visibility,
              label: 'Visibility',
              value: '${weather.visibility?.toStringAsFixed(1)} km',
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return AppDateUtils.formatTime(dateTime);
  }

  Widget _getWeatherIcon(String condition) {
    IconData icon;
    Color color;
    
    switch (condition.toLowerCase()) {
      case 'clear':
        icon = Icons.wb_sunny;
        color = Colors.yellow;
        break;
      case 'clouds':
        icon = Icons.cloud;
        color = Colors.grey;
        break;
      case 'rain':
        icon = Icons.grain;
        color = Colors.blue;
        break;
      case 'drizzle':
        icon = Icons.water_drop;
        color = Colors.lightBlue;
        break;
      case 'thunderstorm':
        icon = Icons.flash_on;
        color = Colors.amber;
        break;
      case 'snow':
        icon = Icons.ac_unit;
        color = Colors.cyan;
        break;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
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

class WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetail({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}