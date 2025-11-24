import 'package:flutter/foundation.dart';

class LocationProvider with ChangeNotifier {
  double _latitude;
  double _longitude;

  LocationProvider({double? latitude, double? longitude})
      : _latitude = latitude ?? 51.5074,
        _longitude = longitude ?? -0.1278;

  double get latitude => _latitude;
  double get longitude => _longitude;

  void update(double lat, double lon) {
    _latitude = lat;
    _longitude = lon;
    notifyListeners();
  }
}
