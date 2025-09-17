import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/routes/app_routes.dart';
import 'package:weather_app/core/utils/date_utils.dart';
import 'package:weather_app/presentation/widgets/weather_card.dart';
import 'package:weather_app/state/weather_provider.dart';
import 'package:weather_app/presentation/widgets/forecast_card.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';
import 'package:weather_app/data/models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _weatherAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _weatherAnimation;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  List<WeatherElement> _weatherElements = [];
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Weather animation controller
    _weatherAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    
    // Fade animation controller
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Weather animation
    _weatherAnimation = CurvedAnimation(
      parent: _weatherAnimationController,
      curve: Curves.linear,
    );
    
    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scrollController.addListener(() {
      if (!_disposed) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });
    
    // Start animations when the screen is first opened
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fadeAnimationController.forward();
      _initializeWeatherData();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _weatherAnimationController.dispose();
    _fadeAnimationController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _weatherAnimationController.repeat();
    } else {
      _weatherAnimationController.stop();
    }
  }

  Future<void> _initializeWeatherData() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    
    if (weatherProvider.weather == null && !weatherProvider.isLoading) {
      await weatherProvider.fetchWeatherByLocation();
    }
  }

  void _generateWeatherElements(String condition) {
    _weatherElements.clear();
    final random = Random();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final hour = DateTime.now().hour;
    final isDay = hour > 6 && hour < 20;
    
    if (condition.toLowerCase().contains('clear') && isDay) {
      // Add sun
      _weatherElements.add(WeatherElement(
        type: WeatherElementType.sun,
        x: screenWidth * 0.8,
        y: screenHeight * 0.15,
        size: 80.0,
        speed: 0.0,
        opacity: 1.0,
      ));
      
      // Add some clouds for visual interest
      for (int i = 0; i < 3; i++) {
        _weatherElements.add(WeatherElement(
          type: WeatherElementType.cloud,
          x: screenWidth * random.nextDouble(),
          y: screenHeight * 0.2 + (random.nextDouble() * 100),
          size: 40.0 + random.nextDouble() * 30,
          speed: 0.2 + random.nextDouble() * 0.3,
          opacity: 0.7 + random.nextDouble() * 0.3,
        ));
      }
    } else if (condition.toLowerCase().contains('clear') && !isDay) {
      // Add moon
      _weatherElements.add(WeatherElement(
        type: WeatherElementType.moon,
        x: screenWidth * 0.8,
        y: screenHeight * 0.15,
        size: 60.0,
        speed: 0.0,
        opacity: 1.0,
      ));
      
      // Add stars
      for (int i = 0; i < 100; i++) {
        _weatherElements.add(WeatherElement(
          type: WeatherElementType.star,
          x: screenWidth * random.nextDouble(),
          y: screenHeight * 0.1 + (random.nextDouble() * screenHeight * 0.5),
          size: 1.0 + random.nextDouble() * 2,
          speed: 0.0,
          opacity: 0.3 + random.nextDouble() * 0.7,
        ));
      }
    } else if (condition.toLowerCase().contains('cloud')) {
      // Add more clouds
      for (int i = 0; i < 8; i++) {
        _weatherElements.add(WeatherElement(
          type: WeatherElementType.cloud,
          x: screenWidth * random.nextDouble(),
          y: screenHeight * 0.15 + (random.nextDouble() * 150),
          size: 50.0 + random.nextDouble() * 40,
          speed: 0.3 + random.nextDouble() * 0.4,
          opacity: 0.7 + random.nextDouble() * 0.3,
        ));
      }
    } else if (condition.toLowerCase().contains('rain')) {
      // Add dark clouds
      for (int i = 0; i < 6; i++) {
        _weatherElements.add(WeatherElement(
          type: WeatherElementType.cloud,
          x: screenWidth * random.nextDouble(),
          y: screenHeight * 0.1 + (random.nextDouble() * 80),
          size: 60.0 + random.nextDouble() * 30,
          speed: 0.4 + random.nextDouble() * 0.3,
          opacity: 0.8 + random.nextDouble() * 0.2,
        ));
      }
      // Add rain
      for (int i = 0; i < 100; i++) {
        _weatherElements.add(WeatherElement(
          type: WeatherElementType.rain,
          x: screenWidth * random.nextDouble(),
          y: screenHeight * random.nextDouble(),
          size: 2.0 + random.nextDouble() * 2,
          speed: 5.0 + random.nextDouble() * 3.0,
          opacity: 0.6 + random.nextDouble() * 0.4,
        ));
      }
    } else if (condition.toLowerCase().contains('snow')) {
      // Add clouds
      for (int i = 0; i < 5; i++) {
        _weatherElements.add(WeatherElement(
          type: WeatherElementType.cloud,
          x: screenWidth * random.nextDouble(),
          y: screenHeight * 0.1 + (random.nextDouble() * 100),
          size: 50.0 + random.nextDouble() * 30,
          speed: 0.3 + random.nextDouble() * 0.2,
          opacity: 0.7 + random.nextDouble() * 0.3,
        ));
      }
      // Add snow
      for (int i = 0; i < 150; i++) {
        _weatherElements.add(WeatherElement(
          type: WeatherElementType.snow,
          x: screenWidth * random.nextDouble(),
          y: screenHeight * random.nextDouble(),
          size: 2.0 + random.nextDouble() * 3,
          speed: 1.0 + random.nextDouble() * 1.5,
          opacity: 0.7 + random.nextDouble() * 0.3,
        ));
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (_disposed) return;
    
    setState(() => _isRefreshing = true);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    await weatherProvider.fetchWeatherByLocation();
    await weatherProvider.refreshForecast();
    
    // Regenerate weather elements based on new condition
    if (weatherProvider.weather != null) {
      _generateWeatherElements(weatherProvider.weather!.condition);
    }
    
    if (!_disposed) {
      setState(() => _isRefreshing = false);
      
      // Add a subtle animation after refresh
      _fadeAnimationController.reset();
      _fadeAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final parallaxOffset = _scrollOffset * 0.5;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(isDarkMode),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          // Generate weather elements if we have weather data
          if (weatherProvider.weather != null && _weatherElements.isEmpty) {
            _generateWeatherElements(weatherProvider.weather!.condition);
          }
          
          return Stack(
            children: [
              // Animated background
              AnimatedBuilder(
                animation: _weatherAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getBackgroundColors(weatherProvider.weather, isDarkMode),
                        stops: const [0.2, 0.6, 1.0],
                      ),
                    ),
                    child: CustomPaint(
                      painter: WeatherElementsPainter(
                        elements: _weatherElements,
                        animation: _weatherAnimation,
                      ),
                    ),
                  );
                },
              ),
              
              // Content
              Transform.translate(
                offset: Offset(0, parallaxOffset),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildContent(weatherProvider, isDarkMode),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  List<Color> _getBackgroundColors(WeatherModel? weather, bool isDarkMode) {
    if (weather == null) {
      return isDarkMode
        ? [const Color(0xFF121212), const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
        : [const Color(0xFF1A237E), const Color(0xFF0D47A1), const Color(0xFF01579B)];
    }
    
    final condition = weather.condition.toLowerCase();
    final hour = DateTime.now().hour;
    final isDay = hour > 6 && hour < 20;
    
    if (condition.contains('clear')) {
      return isDay 
        ? [const Color(0xFF64B5F6), const Color(0xFF42A5F5), const Color(0xFF2196F3)]
        : isDarkMode
          ? [const Color(0xFF0D47A1), const Color(0xFF1A237E), const Color(0xFF000000)]
          : [const Color(0xFF0D47A1), const Color(0xFF1A237E), const Color(0xFF01579B)];
    } else if (condition.contains('cloud')) {
      return isDay
        ? [const Color(0xFF78909C), const Color(0xFF546E7A), const Color(0xFF37474F)]
        : isDarkMode
          ? [const Color(0xFF37474F), const Color(0xFF263238), const Color(0xFF000000)]
          : [const Color(0xFF37474F), const Color(0xFF263238), const Color(0xFF1C1C1C)];
    } else if (condition.contains('rain')) {
      return isDarkMode
        ? [const Color(0xFF37474F), const Color(0xFF263238), const Color(0xFF000000)]
        : [const Color(0xFF546E7A), const Color(0xFF37474F), const Color(0xFF263238)];
    } else if (condition.contains('snow')) {
      return isDarkMode
        ? [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB), const Color(0xFF90CAF9)]
        : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB), const Color(0xFF90CAF9)];
    } else {
      return isDarkMode
        ? [const Color(0xFF121212), const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
        : [const Color(0xFF1A237E), const Color(0xFF0D47A1), const Color(0xFF01579B)];
    }
  }

  Widget _buildContent(WeatherProvider weatherProvider, bool isDarkMode) {
    if (weatherProvider.isLoading && weatherProvider.weather == null) {
      return _buildLoadingState(isDarkMode);
    } else if (weatherProvider.errorMessage != null) {
      return _buildErrorState(weatherProvider.errorMessage!, isDarkMode);
    } else if (weatherProvider.weather != null) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white.withOpacity(0.9),
        color: Colors.blue,
        displacement: 40,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: kToolbarHeight + 24,
            bottom: 20,
          ),
          children: [
            // Main weather card
            WeatherCard(weather: weatherProvider.weather!),
            const SizedBox(height: 24),
            
            // Forecast section
            if (weatherProvider.forecast.isNotEmpty) ...[
              ForecastCard(forecasts: weatherProvider.forecast),
              const SizedBox(height: 24),
            ],
            
            // Additional info
            _buildAdditionalInfo(weatherProvider, isDarkMode),
            const SizedBox(height: 30),
            
            // Footer
            _buildFooter(weatherProvider.lastUpdated, isDarkMode),
          ],
        ),
      );
    } else {
      return _buildEmptyState(isDarkMode);
    }
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: isDarkMode 
        ? SystemUiOverlayStyle.light 
        : SystemUiOverlayStyle.dark,
      title: Text(
        'Weather',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 28,
          color: isDarkMode ? Colors.white : Colors.black,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: Icon(Icons.search, size: 28, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
          tooltip: 'Search city',
        ),
        IconButton(
          icon: Icon(Icons.my_location, size: 28, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: _handleRefresh,
          tooltip: 'Current location',
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        highlightColor: isDarkMode ? Colors.grey[500]! : Colors.grey[100]!,
        period: const Duration(milliseconds: 1200),
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, bool isDarkMode) {
    final bool isLocationError = errorMessage.toLowerCase().contains('permission') ||
                                errorMessage.toLowerCase().contains('location') ||
                                errorMessage.toLowerCase().contains('denied') ||
                                errorMessage.toLowerCase().contains('disabled');
    
    return Center(
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 300,
        borderRadius: 24,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDarkMode ? Colors.white : Colors.black).withOpacity(0.15),
            (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDarkMode ? Colors.white : Colors.black).withOpacity(0.6),
            (isDarkMode ? Colors.white : Colors.black).withOpacity(0.6),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLocationError ? Icons.location_off : Icons.error_outline,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                isLocationError ? 'Location Access Required' : 'Unable to Load Weather Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54, 
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (isLocationError) {
                        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                        if (!serviceEnabled) {
                          await Geolocator.openLocationSettings();
                        }
                        LocationPermission permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                        }
                        _handleRefresh();
                      } else {
                        Provider.of<WeatherProvider>(context, listen: false)
                            .fetchWeatherByLocation();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLocationError ? Colors.orange : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isLocationError ? 'Enable Location' : 'Retry',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                      foregroundColor: isDarkMode ? Colors.white : Colors.black,
                    ),
                    child: const Text(
                      'Search City',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: GlassmorphicContainer(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 300,
        borderRadius: 24,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDarkMode ? Colors.white : Colors.black).withOpacity(0.15),
            (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDarkMode ? Colors.white : Colors.black).withOpacity(0.6),
            (isDarkMode ? Colors.white : Colors.black).withOpacity(0.6),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'No Weather Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Get started by fetching your current weather or searching for a city',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _handleRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Get Weather',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: isDarkMode ? Colors.white : Colors.black),
                      foregroundColor: isDarkMode ? Colors.white : Colors.black,
                    ),
                    child: const Text(
                      'Search City',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(WeatherProvider weatherProvider, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildGlassInfoItem(
            Icons.water_drop, 
            'Humidity', 
            '${weatherProvider.weather?.humidity ?? 0}%',
            isDarkMode,
          ),
          _buildGlassInfoItem(
            Icons.air, 
            'Wind', 
            '${weatherProvider.weather?.windSpeed ?? 0} m/s',
            isDarkMode,
          ),
          _buildGlassInfoItem(
            Icons.visibility, 
            'Visibility', 
            '${weatherProvider.weather?.visibility?.toStringAsFixed(1) ?? 0} km',
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInfoItem(IconData icon, String label, String value, bool isDarkMode) {
    return GlassmorphicContainer(
      width: 100,
      height: 120,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.15),
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.6),
          (isDarkMode ? Colors.white : Colors.black).withOpacity(0.6),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isDarkMode ? Colors.white : Colors.black, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54, 
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black, 
              fontSize: 14, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(DateTime? lastUpdated, bool isDarkMode) {
    final String formattedTime = lastUpdated != null 
        ? 'Last updated: ${AppDateUtils.formatLastUpdated(lastUpdated)}'
        : 'Last updated: Just now';
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Data provided by OpenWeatherMap',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54, 
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedTime,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54, 
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      child: _isRefreshing
          ? FloatingActionButton(
              key: const ValueKey('refreshing'),
              onPressed: null,
              backgroundColor: Colors.blue.withOpacity(0.7),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
                strokeWidth: 3.0,
              ),
            )
          : FloatingActionButton(
              key: const ValueKey('refresh'),
              onPressed: _handleRefresh,
              child: const Icon(Icons.refresh),
              backgroundColor: Colors.blue.withOpacity(0.7),
            ),
    );
  }
}

enum WeatherElementType { sun, moon, cloud, rain, snow, star }

class WeatherElement {
  final WeatherElementType type;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  
  WeatherElement({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class WeatherElementsPainter extends CustomPainter {
  final List<WeatherElement> elements;
  final Animation<double> animation;
  
  WeatherElementsPainter({required this.elements, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (final element in elements) {
      // Calculate position with animation
      final offsetX = element.x + (element.speed * animation.value * size.width);
      final offsetY = element.y + (element.speed * animation.value * size.height);
      
      // Reset position if it goes off screen
      if (offsetX > size.width + element.size || offsetY > size.height + element.size) {
        continue;
      }
      
      switch (element.type) {
        case WeatherElementType.sun:
          _drawSun(canvas, offsetX, offsetY, element.size, element.opacity);
          break;
          
        case WeatherElementType.moon:
          _drawMoon(canvas, offsetX, offsetY, element.size, element.opacity);
          break;
          
        case WeatherElementType.cloud:
          _drawCloud(canvas, offsetX, offsetY, element.size, element.opacity);
          break;
          
case WeatherElementType.rain:
  _drawRain(canvas, offsetX, offsetY, element.size, element.opacity, size);
  break;

          
        case WeatherElementType.snow:
          _drawSnow(canvas, offsetX, offsetY, element.size, element.opacity);
          break;
          
        case WeatherElementType.star:
          _drawStar(canvas, offsetX, offsetY, element.size, element.opacity);
          break;
      }
    }
  }

  void _drawSun(Canvas canvas, double x, double y, double size, double opacity) {
    // Sun glow
    final glowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.3 * opacity)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    
    canvas.drawCircle(Offset(x, y), size * 1.5, glowPaint);
    
    // Sun body
    final sunPaint = Paint()
      ..color = Colors.yellow.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), size, sunPaint);
    
    // Sun rays
    final rayPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.6 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    for (int i = 0; i < 12; i++) {
      final angle = i * pi / 6;
      final startX = x + cos(angle) * size;
      final startY = y + sin(angle) * size;
      final endX = x + cos(angle) * (size * 1.5);
      final endY = y + sin(angle) * (size * 1.5);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  void _drawMoon(Canvas canvas, double x, double y, double size, double opacity) {
    // Moon glow
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2 * opacity)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    canvas.drawCircle(Offset(x, y), size * 1.3, glowPaint);
    
    // Moon body
    final moonPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x, y), size, moonPaint);
    
    // Moon crescent
    final crescentPaint = Paint()
      ..color = const Color(0xFF0D47A1).withOpacity(0.8 * opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(x - size * 0.3, y),
      size * 0.8,
      crescentPaint,
    );
    
    // Moon craters
    final craterPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3 * opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(x - size * 0.2, y - size * 0.2), size * 0.15, craterPaint);
    canvas.drawCircle(Offset(x + size * 0.3, y + size * 0.1), size * 0.1, craterPaint);
    canvas.drawCircle(Offset(x + size * 0.1, y + size * 0.3), size * 0.12, craterPaint);
  }

  void _drawCloud(Canvas canvas, double x, double y, double size, double opacity) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    // Draw multiple overlapping circles to create a cloud shape
    canvas.drawCircle(Offset(x, y), size * 0.6, cloudPaint);
    canvas.drawCircle(Offset(x + size * 0.5, y - size * 0.2), size * 0.5, cloudPaint);
    canvas.drawCircle(Offset(x + size * 0.9, y), size * 0.6, cloudPaint);
    canvas.drawCircle(Offset(x + size * 0.4, y + size * 0.3), size * 0.5, cloudPaint);
    canvas.drawCircle(Offset(x - size * 0.3, y + size * 0.1), size * 0.4, cloudPaint);
  }

 void _drawRain(Canvas canvas, double x, double y, double size, double opacity, Size canvasSize) {
  final rainPaint = Paint()
    ..color = Colors.blue.withOpacity(opacity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = size / 3
    ..strokeCap = StrokeCap.round;

  // Draw raindrop
  canvas.drawLine(
    Offset(x, y),
    Offset(x, y + size * 3),
    rainPaint,
  );

  // Draw splash at the bottom
  if (y > canvasSize.height * 0.8) {
    final splashPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3 * opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y + size * 3), size / 2, splashPaint);
  }
}


  void _drawSnow(Canvas canvas, double x, double y, double size, double opacity) {
    final snowPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    // Draw snowflake center
    canvas.drawCircle(Offset(x, y), size / 3, snowPaint);
    
    // Draw snowflake arms
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final armPaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size / 5;
      
      // Main arm
      canvas.drawLine(
        Offset(x, y),
        Offset(x + cos(angle) * size * 1.5, y + sin(angle) * size * 1.5),
        armPaint,
      );
      
      // Side branches
      for (int j = 1; j <= 2; j++) {
        final branchX = x + cos(angle) * size * (0.5 * j);
        final branchY = y + sin(angle) * size * (0.5 * j);
        
        // Left branch
        canvas.drawLine(
          Offset(branchX, branchY),
          Offset(
            branchX + cos(angle + pi / 4) * size * 0.3,
            branchY + sin(angle + pi / 4) * size * 0.3,
          ),
          armPaint,
        );
        
        // Right branch
        canvas.drawLine(
          Offset(branchX, branchY),
          Offset(
            branchX + cos(angle - pi / 4) * size * 0.3,
            branchY + sin(angle - pi / 4) * size * 0.3,
          ),
          armPaint,
        );
      }
    }
  }

  void _drawStar(Canvas canvas, double x, double y, double size, double opacity) {
    // Twinkling effect
    final twinkle = (sin(animation.value * pi * 2) + 1) / 2;
    final starOpacity = opacity * (0.5 + twinkle * 0.5);
    
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(starOpacity)
      ..style = PaintingStyle.fill;
    
    // Draw a simple star
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = i * pi * 2 / 5 - pi / 2;
      final outerX = x + cos(angle) * size;
      final outerY = y + sin(angle) * size;
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      
      final innerAngle = angle + pi / 5;
      final innerX = x + cos(innerAngle) * size * 0.5;
      final innerY = y + sin(innerAngle) * size * 0.5;
      
      path.lineTo(innerX, innerY);
    }
    path.close();
    
    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(WeatherElementsPainter oldDelegate) {
    return oldDelegate.elements != elements || oldDelegate.animation != animation;
  }
}