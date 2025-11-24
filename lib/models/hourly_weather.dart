class HourlyWeather {
  final List<DateTime> times;
  final List<double> temperatures;
  final List<double> precipitations;

  // Daily summary values (for today) — may be null if missing
  final double? dailyMax;
  final double? dailyMin;
  final double? dailyPrecipitation; // e.g., precipitation_sum

  HourlyWeather({
    required this.times,
    required this.temperatures,
    required this.precipitations,
    this.dailyMax,
    this.dailyMin,
    this.dailyPrecipitation,
  });

  /// Create from Open-Meteo hourly JSON structure
  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    final hourly = json['hourly'] as Map<String, dynamic>?;
    if (hourly == null) {
      throw FormatException('Missing hourly section in response');
    }

    final timesRaw = hourly['time'] as List<dynamic>?;
    final tempsRaw = hourly['temperature_2m'] as List<dynamic>?;
    if (timesRaw == null || tempsRaw == null) {
      throw FormatException('Missing time or temperature_2m fields');
    }

    final times = timesRaw
        .map<DateTime>((t) => DateTime.parse(t as String))
        .toList();
    final temps = tempsRaw.map<double>((t) {
      if (t == null) return double.nan;
      return (t as num).toDouble();
    }).toList();

    final precRaw = hourly['precipitation'] as List<dynamic>?;
    final precs = precRaw != null
        ? precRaw.map<double>((p) => (p as num).toDouble()).toList()
        : List<double>.filled(times.length, 0.0);

    // Daily summary values
    final daily = json['daily'] as Map<String, dynamic>?;
    double? dailyMax;
    double? dailyMin;
    double? dailyPrecip;
    if (daily != null) {
      final maxRaw = daily['temperature_2m_max'] as List<dynamic>?;
      final minRaw = daily['temperature_2m_min'] as List<dynamic>?;
      final precDailyRaw = daily['precipitation_sum'] as List<dynamic>?;
      if (maxRaw != null && maxRaw.isNotEmpty)
        dailyMax = (maxRaw[0] as num).toDouble();
      if (minRaw != null && minRaw.isNotEmpty)
        dailyMin = (minRaw[0] as num).toDouble();
      if (precDailyRaw != null && precDailyRaw.isNotEmpty)
        dailyPrecip = (precDailyRaw[0] as num).toDouble();
    }

    return HourlyWeather(
      times: times,
      temperatures: temps,
      precipitations: precs,
      dailyMax: dailyMax,
      dailyMin: dailyMin,
      dailyPrecipitation: dailyPrecip,
    );
  }
}
