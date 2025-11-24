// dart:math removed — not needed anymore
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../models/hourly_weather.dart';
import '../providers/location_provider.dart';
import 'menu_page.dart';
import 'add_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // coordinates are taken from LocationProvider now

  final _service = WeatherService();

  HourlyWeather? _weather;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // initial load and subscribe to location changes
      final loc = Provider.of<LocationProvider>(context, listen: false);
      loc.addListener(_onLocationChanged);
      _load();
    });
  }

  void _onLocationChanged() {
    // reload weather when location provider changes
    _load();
  }

  Future<void> _load() async {
    // Clear previous weather while loading
    setState(() => _weather = null);

    try {
      final loc = Provider.of<LocationProvider>(context, listen: false);
      final w = await _service.fetchHourly(
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
      setState(() => _weather = w);
    } catch (e) {
      // Show a transient error to the user instead of keeping state fields
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading weather data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(62, 45, 143, 1),
              Color.fromRGBO(157, 82, 172, 0.7),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top weather image
              Image.asset(
                'assets/weathers.png',
                height: 120.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 8.h),

              // Big max temperature (or placeholder)
              Text(
                _weather?.dailyMax != null
                    ? '${_weather!.dailyMax!.toStringAsFixed(1)}°C'
                    : '--°C',
                style: TextStyle(fontSize: 40.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),

              // Precipitation
              Text(
                'Precipitation: ${_weather?.dailyPrecipitation != null ? '${_weather!.dailyPrecipitation!.toStringAsFixed(1)} mm' : '--'}',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),

              // Max and Min text
              Text(
                'Max: ${_weather?.dailyMax != null ? '${_weather!.dailyMax!.toStringAsFixed(1)}°C' : '--'}  •  Min: ${_weather?.dailyMin != null ? '${_weather!.dailyMin!.toStringAsFixed(1)}°C' : '--'}',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 12.h),

              // House image
              Image.asset('assets/house.png', fit: BoxFit.contain),

              // Card enclosing the hourly list with a subtle gradient background
              if (_weather != null)
                Card(
                  margin: EdgeInsets.only(bottom: 40.h),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(62, 45, 143, 1),
                          Color.fromRGBO(157, 82, 172, 0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Today',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                DateFormat.MMMd().format(DateTime.now()),
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                          ],
                        ),

                        // white horizontal line under the Today / date row
                        const Divider(
                          color: Colors.white,
                          thickness: 1,
                          height: 1,
                        ),

                        SizedBox(
                          height: 140.h,
                          child: _buildHourlyList(_weather!),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      // Bottom navigation bar with three buttons: Location, Add, Menu
      bottomNavigationBar: SafeArea(
        child: Container(
          // subtle translucent background so the gradient shows through
          color: Colors.transparent,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: (idx) {
              setState(() => _selectedIndex = idx);
              // Basic actions for each button
              if (idx == 0) {
                // Location: open the HomePage (clear stack) so the home screen is shown
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              } else if (idx == 1) {
                // Add: open AddPage to change coordinates
                if (mounted) {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const AddPage()));
                }
              } else if (idx == 2) {
                // Menu: open MenuPage
                if (mounted) {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const MenuPage()));
                }
              }
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      final loc = Provider.of<LocationProvider>(context, listen: false);
      loc.removeListener(_onLocationChanged);
    } catch (_) {}
    super.dispose();
  }

  Widget _buildHourlyList(HourlyWeather weather) {
    final now = DateTime.now();
    final formatter = DateFormat.Hm();

    // Simpler: build a list of time/temp pairs starting at now and take up to 48
    final pairs = Iterable<int>.generate(weather.times.length)
        .map((i) => MapEntry(weather.times[i], weather.temperatures[i]))
        .where((e) => !e.key.isBefore(now))
        .take(48)
        .toList();

    if (pairs.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: pairs.map((entry) {
          final time = entry.key;
          final temp = entry.value;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(formatter.format(time), style: TextStyle(fontSize: 12.sp)),

                Image.asset('assets/weather_small.png', fit: BoxFit.contain),

                Text(
                  '${temp.toStringAsFixed(1)}°C',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
