class QuranReciter {
  final String identifier;
  final String serverUrl;
  final String nameArabic;
  final String nameEnglish;
  final String style;

  const QuranReciter({
    required this.identifier,
    required this.serverUrl,
    required this.nameArabic,
    required this.nameEnglish,
    this.style = 'مرتل',
  });

  String getAudioUrl(int surahNumber) {
    final paddedNumber = surahNumber.toString().padLeft(3, '0');
    return '$serverUrl/$paddedNumber.mp3';
  }
}

const List<QuranReciter> defaultQuranReciters = [
  QuranReciter(
    identifier: 'ar.alafasy',
    serverUrl: 'https://server8.mp3quran.net/afs',
    nameArabic: 'مشاري راشد العفاسي',
    nameEnglish: 'Mishary Rashid Alafasy',
  ),
  QuranReciter(
    identifier: 'ar.abdulbasitmurattal',
    serverUrl: 'https://server7.mp3quran.net/basit',
    nameArabic: 'عبد الباسط عبد الصمد',
    nameEnglish: 'Abdul Basit Abdul Samad',
    style: 'مرتل',
  ),
  QuranReciter(
    identifier: 'ar.abdurrahmaansudais',
    serverUrl: 'https://server11.mp3quran.net/sds',
    nameArabic: 'عبد الرحمن السديس',
    nameEnglish: 'Abdurrahman As-Sudais',
  ),
  QuranReciter(
    identifier: 'ar.saadghamadi',
    serverUrl: 'https://server7.mp3quran.net/s_gmd',
    nameArabic: 'سعد الغامدي',
    nameEnglish: 'Saad Al-Ghamdi',
  ),
  QuranReciter(
    identifier: 'ar.mahermuaiqly',
    serverUrl: 'https://server12.mp3quran.net/maher',
    nameArabic: 'ماهر المعيقلي',
    nameEnglish: 'Maher Al-Muaiqly',
  ),
  QuranReciter(
    identifier: 'ar.minshawi',
    serverUrl: 'https://server10.mp3quran.net/minsh',
    nameArabic: 'محمد صديق المنشاوي',
    nameEnglish: 'Mohamed Siddiq El-Minshawi',
    style: 'مرتل',
  ),
  QuranReciter(
    identifier: 'ar.shaatree',
    serverUrl: 'https://server11.mp3quran.net/shatri',
    nameArabic: 'أبو بكر الشاطري',
    nameEnglish: 'Abu Bakr Al-Shatri',
  ),
  QuranReciter(
    identifier: 'ar.hudhaify',
    serverUrl: 'https://server9.mp3quran.net/hthfi',
    nameArabic: 'علي بن عبد الرحمن الحذيفي',
    nameEnglish: 'Ali Al-Hudhaify',
  ),
];
