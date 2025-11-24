class DailyForecast {
  final List<DateTime> dates;
  final List<double> maxTemps;
  final List<double> minTemps;
  final List<double> precipitationSums;
  // sunrise/sunset strings returned by the API (ISO datetimes)
  final List<String> sunrises;
  final List<String> sunsets;
  // UV index maximum per day (if provided)
  final List<double> uvIndexMax;

  DailyForecast({
    required this.dates,
    required this.maxTemps,
    required this.minTemps,
    required this.precipitationSums,
    List<String>? sunrises,
    List<String>? sunsets,
    List<double>? uvIndexMax,
  }) : sunrises = sunrises ?? List<String>.filled(dates.length, ''),
       sunsets = sunsets ?? List<String>.filled(dates.length, ''),
       uvIndexMax = uvIndexMax ?? List<double>.filled(dates.length, 0.0);

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final daily = json['daily'] as Map<String, dynamic>?;
    if (daily == null) throw FormatException('Missing daily section');

    final datesRaw = daily['time'] as List<dynamic>?;
    final maxRaw = daily['temperature_2m_max'] as List<dynamic>?;
    final minRaw = daily['temperature_2m_min'] as List<dynamic>?;
    final precRaw = daily['precipitation_sum'] as List<dynamic>?;

    if (datesRaw == null || maxRaw == null || minRaw == null) {
      throw FormatException('Incomplete daily data');
    }

    final dates = datesRaw
        .map<DateTime>((d) => DateTime.parse(d as String))
        .toList();
    final maxTemps = maxRaw.map<double>((v) => (v as num).toDouble()).toList();
    final minTemps = minRaw.map<double>((v) => (v as num).toDouble()).toList();
    final precs = precRaw != null
        ? precRaw.map<double>((v) => (v as num).toDouble()).toList()
        : List<double>.filled(dates.length, 0.0);

    final sunrises =
        (daily['sunrise'] as List<dynamic>?)
            ?.map((s) => s as String)
            .toList() ??
        List<String>.filled(dates.length, '');
    final sunsets =
        (daily['sunset'] as List<dynamic>?)?.map((s) => s as String).toList() ??
        List<String>.filled(dates.length, '');
    final uvRaw = (daily['uv_index_max'] as List<dynamic>?) ?? <dynamic>[];
    final uvIndexMax = uvRaw.isNotEmpty
        ? uvRaw.map<double>((v) => (v as num).toDouble()).toList()
        : List<double>.filled(dates.length, 0.0);

    return DailyForecast(
      dates: dates,
      maxTemps: maxTemps,
      minTemps: minTemps,
      precipitationSums: precs,
      sunrises: sunrises,
      sunsets: sunsets,
      uvIndexMax: uvIndexMax,
    );
  }
}
