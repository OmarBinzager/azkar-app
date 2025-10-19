import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../model/prayer_times_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final prayerTimesProvider = FutureProvider<PrayerTimesModel>((ref) async {
  late PrayerTimesModel prayerTimes;
  late tz.Location location;
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

  String formatTo12Hour(DateTime time) {
    return DateFormat.jm().format(time); // e.g., 5:30 PM
  }

  TimeOfDay parseTimeOfDay(String timeString) {
    final dateTime = DateFormat.jm().parse(timeString); // e.g., "5:30 PM"
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  Future<String?> getCityName(Position position) async {
    // Get placemarks
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      return place.locality; // This gives you the city name
    }

    return 'City not found';
  }

  Future<tz.Location> getCurrentTimezone() async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    return tz.getLocation(currentTimeZone);

  }

  Future calculatePrayerTimesFromLocation() async {
    try {
      tz.initializeTimeZones();
      Position position = await getCurrentLocation();
      final coordinates = Coordinates(position.latitude, position.longitude);
      location = await getCurrentTimezone();
      final params = CalculationMethod.ummAlQura();
      final date = DateTime.now();
      HijriCalendar todayHijri = getHijriDate();
      final times = PrayerTimes(
        coordinates: coordinates,
        date: date,
        calculationParameters: params,
        precision: true,
      );
      String? cityName = await getCityName(position);
      prayerTimes = PrayerTimesModel(
        city: cityName,
        hijriDate: todayHijri.toFormat('yyyy MM dd'),
        fajrAsString: formatTo12Hour(tz.TZDateTime.from(times.fajr!, location)),
        fajr: times.fajr!,
        sunriseAsString: formatTo12Hour(
          tz.TZDateTime.from(times.sunrise!, location),
        ),
        sunrise: times.sunrise!,
        dhuhrAsString: formatTo12Hour(
          tz.TZDateTime.from(times.dhuhr!, location),
        ),
        dhuhr: times.dhuhr!,
        asrAsString: formatTo12Hour(tz.TZDateTime.from(times.asr!, location)),
        asr: times.asr!,
        maghribAsString: formatTo12Hour(
          tz.TZDateTime.from(times.maghrib!, location),
        ),
        maghrib: times.maghrib!,
        ishaAsString: formatTo12Hour(tz.TZDateTime.from(times.isha!, location)),
        isha: times.isha!,
      );
    } catch (e) {
      print('Error getting location or prayer times: $e');
    }
    return null;
  }

  getNextPrayer() {
    TimeOfDay now = TimeOfDay.now();

    try {
      TimeOfDay fajr = parseTimeOfDay(prayerTimes.fajrAsString);

      TimeOfDay sunrise = parseTimeOfDay(prayerTimes.sunriseAsString!);

      TimeOfDay dhuhr = parseTimeOfDay(prayerTimes.dhuhrAsString);

      TimeOfDay asr = parseTimeOfDay(prayerTimes.asrAsString);

      TimeOfDay maghrib = parseTimeOfDay(prayerTimes.maghribAsString);

      TimeOfDay isha = parseTimeOfDay(prayerTimes.ishaAsString);

      if (now.isAfter(fajr) && now.isBefore(sunrise)) {
        prayerTimes.nextPrayerName = 'شروق';
        prayerTimes.nextPrayerTime = prayerTimes.dhuhrAsString;
      } else if (now.isAfter(sunrise) && now.isBefore(dhuhr)) {
        prayerTimes.nextPrayerName = 'ظهر';
        prayerTimes.nextPrayerTime = prayerTimes.dhuhrAsString;
      } else if (now.isAfter(dhuhr) && now.isBefore(asr)) {
        prayerTimes.nextPrayerName = 'عصر';
        prayerTimes.nextPrayerTime = prayerTimes.asrAsString;
      } else if (now.isAfter(asr) && now.isBefore(maghrib)) {
        prayerTimes.nextPrayerName = 'مغرب';
        prayerTimes.nextPrayerTime = prayerTimes.maghribAsString;
      } else if (now.isAfter(maghrib) && now.isBefore(isha)) {
        prayerTimes.nextPrayerName = 'عشاء';
        prayerTimes.nextPrayerTime = prayerTimes.ishaAsString;
      } else if (now.isAfter(isha) && now.isBefore(fajr)) {
        prayerTimes.nextPrayerName = 'فجر';
        prayerTimes.nextPrayerTime = prayerTimes.fajrAsString;
      }
    } catch (e) {
      print('error in getNextPrayer $e');
    }
  }


  await calculatePrayerTimesFromLocation().then((_) {
    if (prayerTimes == null) {
      throw Exception('Failed to calculate prayer times');
    }
    getNextPrayer();
  });

  return prayerTimes;
});

HijriCalendar getHijriDate() {
  HijriCalendar.setLocal("ar"); // or "en" for English
  final todayHijri = HijriCalendar.now();
  return todayHijri;
}
