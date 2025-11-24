import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/weather_service.dart';
import '../models/daily_forecast.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final _service = WeatherService();
  DailyForecast? _forecast;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      // subscribe to location changes
      final loc = Provider.of<LocationProvider>(context, listen: false);
      loc.addListener(_onLocationChange);
    });
  }

  void _onLocationChange() {
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final loc = Provider.of<LocationProvider>(context, listen: false);
      final f = await _service.fetch7DayForecast(
        latitude: loc.latitude,
        longitude: loc.longitude,
      );
      setState(() {
        _forecast = f;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatSunTime(int dayIndex, bool isSunrise) {
    if (_forecast == null) return '--:--';
    final list = isSunrise ? _forecast!.sunrises : _forecast!.sunsets;
    if (list.isEmpty || list.length <= dayIndex || list[dayIndex].isEmpty)
      return '--:--';
    try {
      final dt = DateTime.parse(list[dayIndex]);
      return DateFormat.jm().format(dt);
    } catch (_) {
      return list[dayIndex];
    }
  }

  String _formatUvValue() {
    if (_forecast == null) return '--';
    if (_forecast!.uvIndexMax.isEmpty) return '--';
    final v = _forecast!.uvIndexMax[0];
    return v.isFinite ? v.toStringAsFixed(0) : '--';
  }

  String _uvRiskLabel() {
    if (_forecast == null || _forecast!.uvIndexMax.isEmpty) return '--';
    final v = _forecast!.uvIndexMax[0];
    if (v <= 2) return 'Low';
    if (v <= 5) return 'Moderate';
    if (v <= 7) return 'High';
    return 'Very High';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(backgroundColor: Color.fromRGBO(62, 45, 143, 1)),
      backgroundColor: Colors.transparent,
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
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                  'Latitude: ${Provider.of<LocationProvider>(context).latitude.toStringAsFixed(4)}\nLongitude: ${Provider.of<LocationProvider>(context).longitude.toStringAsFixed(4)}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            

            // Today's min/max (centered)
            if (_forecast != null && _forecast!.dates.isNotEmpty)
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Max: ${_forecast!.maxTemps[0].toStringAsFixed(1)}°C',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Min: ${_forecast!.minTemps[0].toStringAsFixed(1)}°C',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else if (_loading)
              const Center(child: CircularProgressIndicator()),

            SizedBox(height: 16.h),

            // 7-day horizontal list
            SizedBox(height: 8.h),
            if (_forecast != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '7-day forecast',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 150.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _forecast!.dates.length,
                      itemBuilder: (context, index) {
                        final date = _forecast!.dates[index];
                        final max = _forecast!.maxTemps[index];
                        final dayName = DateFormat.E().format(date); // Mon, Tue

                        return Container(
                          width: 60.w,
                          height: 250.h,
                          margin: EdgeInsets.only(right: 8.w),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(48.r),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${max.toStringAsFixed(1)}°C',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Image.asset('assets/weather_small.png'),
                              SizedBox(height: 6.h),
                              Text(dayName, style: TextStyle(fontSize: 12.sp)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            else if (!_loading)
              const Text('No forecast available'),

            SizedBox(height: 16.h),

            // Air Quality card
            Card(
              color: Colors.white.withOpacity(0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Air Quality',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Text(
                      '3-Low Health Risk',
                      style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),

                    SizedBox(height: 12.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'See more',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.white.withOpacity(0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.wb_sunny, color: Colors.white),
                              Text(
                                'Sunrise',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _formatSunTime(0, true),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Sunset: ${_formatSunTime(0, false)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Card(
                    color: Colors.white.withOpacity(0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.wb_sunny, color: Colors.white),
                              Text(
                                'UV Index',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _formatUvValue(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _uvRiskLabel(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      final loc = Provider.of<LocationProvider>(context, listen: false);
      loc.removeListener(_onLocationChange);
    } catch (_) {}
    super.dispose();
  }
}
