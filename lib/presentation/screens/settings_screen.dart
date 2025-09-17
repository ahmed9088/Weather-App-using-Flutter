import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/state/theme_provider.dart';
import 'package:weather_app/state/weather_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isCelsius = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('General Settings'),
          _buildTemperatureUnitSetting(),
          _buildThemeSetting(themeProvider),
          _buildLanguageSetting(),
          const SizedBox(height: 24),
          _buildSectionHeader('Notifications'),
          _buildNotificationSetting(),
          const SizedBox(height: 24),
          _buildSectionHeader('Data & Privacy'),
          _buildClearRecentSearches(),
          _buildPrivacyPolicy(),
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildAppVersion(),
          _buildDeveloperInfo(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTemperatureUnitSetting() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Temperature Unit'),
        subtitle: Text(_isCelsius ? 'Celsius (°C)' : 'Fahrenheit (°F)'),
        trailing: Switch(
          value: _isCelsius,
          onChanged: (value) {
            setState(() {
              _isCelsius = value;
            });
            _showSnackBar('Temperature unit changed to ${_isCelsius ? 'Celsius' : 'Fahrenheit'}');
          },
        ),
        leading: const Icon(Icons.thermostat),
      ),
    );
  }

  Widget _buildThemeSetting(ThemeProvider themeProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Dark Mode'),
        subtitle: const Text('Enable dark theme'),
        trailing: Switch(
          value: themeProvider.isDark,
          onChanged: (value) {
            themeProvider.toggleTheme();
            _showSnackBar('Dark mode ${themeProvider.isDark ? 'enabled' : 'disabled'}');
          },
        ),
        leading: Icon(themeProvider.isDark ? Icons.dark_mode : Icons.light_mode),
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Language'),
        subtitle: Text(_selectedLanguage),
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: const Icon(Icons.language),
        onTap: () => _showLanguageDialog(),
      ),
    );
  }

  Widget _buildNotificationSetting() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Weather Alerts'),
        subtitle: const Text('Get notified about severe weather'),
        trailing: Switch(
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            _showSnackBar('Weather alerts ${_notificationsEnabled ? 'enabled' : 'disabled'}');
          },
        ),
        leading: const Icon(Icons.notifications),
      ),
    );
  }

  Widget _buildClearRecentSearches() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Clear Recent Searches'),
        subtitle: const Text('Remove all recent search history'),
        leading: const Icon(Icons.delete_outline),
        onTap: () => _showClearSearchesDialog(),
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Privacy Policy'),
        subtitle: const Text('Read our privacy policy'),
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: const Icon(Icons.security),
        onTap: () => _showPrivacyPolicy(),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('App Version'),
        subtitle: const Text('1.0.0'),
        leading: const Icon(Icons.system_update),
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: const Text('Developer'),
        subtitle: const Text('Weather App Team'),
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: const Icon(Icons.people),
        onTap: () => _showDeveloperDialog(),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              return RadioListTile<String>(
                title: Text(language),
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                  Navigator.pop(context);
                  _showSnackBar('Language changed to $language');
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showClearSearchesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Recent Searches'),
        content: const Text('Are you sure you want to clear all recent searches?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Recent searches cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Weather App respects your privacy. This app collects location data to provide weather '
            'information for your current location. This data is used solely for the purpose of '
            'displaying weather information and is not shared with third parties.\n\n'
            'The app may store your recent search history locally on your device to improve '
            'your experience. You can clear this data at any time from the settings.\n\n'
            'Weather App uses the OpenWeatherMap API to fetch weather data. For more information '
            'about their privacy practices, please visit their website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Developer Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weather App Team'),
            SizedBox(height: 8),
            Text('Contact: support@weatherapp.com'),
            SizedBox(height: 8),
            Text('Website: www.weatherapp.com'),
            SizedBox(height: 8),
            Text('GitHub: github.com/weatherapp'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Weather App',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.cloud, size: 48),
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            'This app provides current weather information for any city worldwide. '
            'Data is provided by OpenWeatherMap API.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}