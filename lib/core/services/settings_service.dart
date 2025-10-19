import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _fontSizeKey = 'font_size';
  static const String _autoPlayAudioKey = 'auto_play_audio';
  static const String _quranFontFamilyKey = 'quran_font_family';
  static const String _contentFontFamilyKey = 'content_font_family';
  static const String _nightModeKey = 'night_mode';


  static const double _defaultFontSize = 22.0;
  static const bool _defaultAutoPlayAudio = false;
  static const String _defaultQuranFontFamily = 'UthmanicHafs_V20';
  static const String _defaultContentFontFamily = 'Lotus';
  static const bool _defaultNightMode = false;

  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences> get _prefs async {
    if (_prefsInstance != null) {
      return _prefsInstance!;
    }
    _prefsInstance = await SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  // Get font size setting
  static Future<double> getFontSize() async {
    try {
      final prefs = await _prefs;
      final fontSize = prefs.getDouble(_fontSizeKey) ?? _defaultFontSize;
      return fontSize;
    } catch (e) {
      return _defaultFontSize;
    }
  }

  // Save font size setting
  static Future<void> setFontSize(double fontSize) async {
    try {
      final prefs = await _prefs;
      await prefs.setDouble(_fontSizeKey, fontSize);
    } catch (e) {
      // Try again with a small delay
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        final prefs = await _prefs;
        await prefs.setDouble(_fontSizeKey, fontSize);
      } catch (e2) {
        // Ignore second error
      }
    }
  }

  // Get auto play audio setting
  static Future<bool> getAutoPlayAudio() async {
    try {
      final prefs = await _prefs;
      final autoPlay =
          prefs.getBool(_autoPlayAudioKey) ?? _defaultAutoPlayAudio;
      return autoPlay;
    } catch (e) {
      return _defaultAutoPlayAudio;
    }
  }

  // Save auto play audio setting
  static Future<void> setAutoPlayAudio(bool autoPlay) async {
    try {
      final prefs = await _prefs;
      await prefs.setBool(_autoPlayAudioKey, autoPlay);
    } catch (e) {
      // Try again with a small delay
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        final prefs = await _prefs;
        await prefs.setBool(_autoPlayAudioKey, autoPlay);
      } catch (e2) {
        // Ignore second error
      }
    }
  }

  // Get Quran font family
  static Future<String> getQuranFontFamily() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_quranFontFamilyKey) ?? _defaultQuranFontFamily;
    } catch (e) {
      return _defaultQuranFontFamily;
    }
  }

  // Set Quran font family
  static Future<void> setQuranFontFamily(String fontFamily) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_quranFontFamilyKey, fontFamily);
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        final prefs = await _prefs;
        await prefs.setString(_quranFontFamilyKey, fontFamily);
      } catch (e2) {}
    }
  }

  // Get content font family
  static Future<String> getContentFontFamily() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_contentFontFamilyKey) ??
          _defaultContentFontFamily;
    } catch (e) {
      return _defaultContentFontFamily;
    }
  }

  // Set content font family
  static Future<void> setContentFontFamily(String fontFamily) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_contentFontFamilyKey, fontFamily);
    } catch (e) {
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        final prefs = await _prefs;
        await prefs.setString(_contentFontFamilyKey, fontFamily);
      } catch (e2) {}
    }
  }

  // Get night mode setting
  static Future<bool> getNightMode() async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(_nightModeKey) ?? _defaultNightMode;
    } catch (e) {
      return _defaultNightMode;
    }
  }

  // Save night mode setting
  static Future<void> setNightMode(bool nightMode) async {
    try {
      final prefs = await _prefs;
      await prefs.setBool(_nightModeKey, nightMode);
    } catch (e) {
      // Try again with a small delay
      try {
        await Future.delayed(const Duration(milliseconds: 100));
        final prefs = await _prefs;
        await prefs.setBool(_nightModeKey, nightMode);
      } catch (e2) {
        // Ignore second error
      }
    }
  }

  // Reset all settings to defaults
  static Future<void> resetToDefaults() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_fontSizeKey);
      await prefs.remove(_autoPlayAudioKey);
      await prefs.remove(_quranFontFamilyKey);
      await prefs.remove(_contentFontFamilyKey);
      await prefs.remove(_nightModeKey);
    } catch (e) {
      // Ignore error
    }
  }

  // Clear cached instance (useful for debugging)
  static void clearCache() {
    _prefsInstance = null;
  }

  // Force reinitialize SharedPreferences
  static Future<void> reinitialize() async {
    _prefsInstance = null;
    try {
      _prefsInstance = await SharedPreferences.getInstance();
    } catch (e) {
      // Ignore error
    }
  }
}
