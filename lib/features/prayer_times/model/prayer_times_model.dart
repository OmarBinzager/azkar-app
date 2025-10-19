class PrayerTimesModel {
  String fajrAsString;
  DateTime fajr;
  String dhuhrAsString;
  DateTime dhuhr;
  String asrAsString;
  DateTime asr;
  String maghribAsString;
  DateTime maghrib;
  String ishaAsString;
  DateTime isha;
  String? city;
  String? nextPrayerName;
  String? nextPrayerTime;
  String? sunriseAsString;
  DateTime? sunrise;
  String? sunsetAsString;
  DateTime? sunset;
  String? hijriDate;

  PrayerTimesModel({
    required this.fajrAsString,
    required this.dhuhrAsString,
    required this.asrAsString,
    required this.maghribAsString,
    required this.ishaAsString,
    this.city,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.nextPrayerName,
    this.nextPrayerTime,
    this.sunriseAsString,
    this.sunrise,
    this.sunsetAsString,
    this.sunset,
    this.hijriDate,
  });

  /// Returns a map with the next prayer's name, DateTime, and time remaining as a string
  Map<String, dynamic> getNextPrayerInfo(DateTime now) {
    final prayers = [
      {'name': 'الفجر', 'time': fajr},
      {'name': 'الظهر', 'time': dhuhr},
      {'name': 'العصر', 'time': asr},
      {'name': 'المغرب', 'time': maghrib},
      {'name': 'العشاء', 'time': isha},
    ];
    for (final prayer in prayers) {
      final DateTime? prayerTime = prayer['time'] as DateTime?;
      if (prayerTime != null && prayerTime.isAfter(now)) {
        final difference = prayerTime.difference(now);
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        return {
          'name': prayer['name'],
          'time': prayerTime,
          'timeRemaining': '${hours}س ${minutes}د',
        };
      }
    }
    // If no next prayer today, return first prayer of tomorrow
    final DateTime? fajrTime = fajr;
    if (fajrTime != null) {
      final tomorrowFajr = fajrTime.add(const Duration(days: 1));
      final difference = tomorrowFajr.difference(now);
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      return {
        'name': 'الفجر',
        'time': tomorrowFajr,
        'timeRemaining': '${hours}س ${minutes}د',
      };
    }
    // fallback if all times are null
    return {'name': '', 'time': null, 'timeRemaining': ''};
  }
}
