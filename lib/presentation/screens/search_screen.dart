import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/constants/app_constants.dart';
import 'package:weather_app/state/weather_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    // Load recent searches (in a real app, this would come from shared preferences)
    _loadRecentSearches();
    // Focus the text field when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _loadRecentSearches() {
    // In a real app, you would load from shared preferences
    // For now, we'll use a default list
    setState(() {
      _recentSearches = [
        'London',
        'New York',
        'Tokyo',
        'Paris',
        'Sydney'
      ];
    });
  }

  void _saveRecentSearch(String city) {
    setState(() {
      // Remove if already exists to avoid duplicates
      _recentSearches.remove(city);
      // Add to beginning of list
      _recentSearches.insert(0, city);
      // Keep only the 5 most recent searches
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });
    // In a real app, save to shared preferences
  }

Future<void> _searchWeather() async {
  final cityName = _controller.text.trim();
  
  if (cityName.isEmpty) {
    setState(() {
      _errorMessage = 'Please enter a city name';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    await Provider.of<WeatherProvider>(context, listen: false)
        .fetchWeatherByCity(cityName);
    
    // Save to recent searches on success
    _saveRecentSearch(cityName);
    
    if (mounted) {
      Navigator.pop(context);
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'City not found. Please try again.';
    });
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _isLoading ? null : _searchWeather,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _buildRecentSearchesSection(),
            const SizedBox(height: 24),
            _buildPopularCitiesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _searchWeather(),
      decoration: InputDecoration(
        labelText: 'Enter city name',
        hintText: 'e.g. London, Tokyo, New York',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        prefixIcon: const Icon(Icons.location_city),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    _errorMessage = null;
                  });
                },
              )
            : null,
      ),
      onChanged: (value) {
        if (_errorMessage != null) {
          setState(() {
            _errorMessage = null;
          });
        }
      },
    );
  }

  Widget _buildRecentSearchesSection() {
    if (_recentSearches.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Searches',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentSearches.map((city) {
            return ActionChip(
              label: Text(city),
              avatar: const Icon(Icons.history, size: 18),
              backgroundColor: Colors.blue.shade50,
              onPressed: () {
                _controller.text = city;
                _searchWeather();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularCitiesSection() {
    final popularCities = [
      'London', 'New York', 'Tokyo', 'Paris', 'Sydney',
      'Dubai', 'Singapore', 'Los Angeles', 'Barcelona', 'Toronto'
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Cities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: popularCities.length,
          itemBuilder: (context, index) {
            final city = popularCities[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  _controller.text = city;
                  _searchWeather();
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_city,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          city,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}