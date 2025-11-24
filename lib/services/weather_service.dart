import 'package:dio/dio.dart';
import '../models/hourly_weather.dart';
import '../models/daily_forecast.dart';

class WeatherService {
  final Dio _dio;

  WeatherService([Dio? dio]) : _dio = dio ?? Dio();

  /// Fetch hourly temperature data from Open-Meteo for given latitude/longitude.
  Future<HourlyWeather> fetchHourly({
    required double latitude,
    required double longitude,
  }) async {
    final url = 'https://api.open-meteo.com/v1/forecast';

    final params = {
      'latitude': latitude,
      'longitude': longitude,

      'hourly': 'temperature_2m,precipitation',
      'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum',
      'current_weather': true,
      'timezone': 'auto',
    };

    final response = await _dio.get(url, queryParameters: params);
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      return HourlyWeather.fromJson(data);
    }

    throw Exception(
      'Failed to fetch weather data, status: ${response.statusCode}',
    );
  }

  /// Fetch 7-day daily forecast (time, max/min temps, precipitation_sum)
  Future<DailyForecast> fetch7DayForecast({
    required double latitude,
    required double longitude,
  }) async {
    final url = 'https://api.open-meteo.com/v1/forecast';

    final params = {
      'latitude': latitude,
      'longitude': longitude,
      'daily':
          'temperature_2m_max,temperature_2m_min,precipitation_sum,sunrise,sunset,uv_index_max',
      'timezone': 'auto',
    };

    final response = await _dio.get(url, queryParameters: params);
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      return DailyForecast.fromJson(data);
    }

    throw Exception(
      'Failed to fetch daily forecast, status: ${response.statusCode}',
    );
  }
}
