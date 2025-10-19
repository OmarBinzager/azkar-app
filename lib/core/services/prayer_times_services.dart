import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/data/latest.dart' as tz;

class PrayerTimesServices {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<PrayerTimes?> calculatePrayerTimesFromLocation() async {
    try {
      tz.initializeTimeZones();
      Position position = await getCurrentLocation();
      final coordinates = Coordinates(position.latitude, position.longitude);
      //final location = tz.getLocation('Asia/Aden');
      final params = CalculationMethod.muslimWorldLeague();
      final date = DateTime.now();

      final prayerTimes = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
          precision: true
      );

      return prayerTimes;

    } catch (e) {
      printToConsole('Error getting location or prayer times: $e');
    }
    return null;
  }
}
