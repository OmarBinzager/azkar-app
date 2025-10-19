import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_azkar_app/core/services/settings_service.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final autoPlay = await SettingsService.getAutoPlayAudio();
      final fontSize = await SettingsService.getFontSize();
      final quranFontFamily = await SettingsService.getQuranFontFamily();
      final contentFontFamily = await SettingsService.getContentFontFamily();
      final nightMode = await SettingsService.getNightMode();

      state = state.copyWith(
        autoPlayAudio: autoPlay,
        fontSize: fontSize,
        quranFontFamily: quranFontFamily,
        contentFontFamily: contentFontFamily,
        nightMode: nightMode,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setAutoPlayAudio(bool value) async {
    try {
      await SettingsService.setAutoPlayAudio(value);
      state = state.copyWith(autoPlayAudio: value);
    } catch (e) {
      // Try to reinitialize SharedPreferences
      try {
        await SettingsService.reinitialize();
        await SettingsService.setAutoPlayAudio(value);
        state = state.copyWith(autoPlayAudio: value);
      } catch (e2) {
        // Still update the state even if saving fails
        state = state.copyWith(autoPlayAudio: value);
      }
    }
  }

  Future<void> setFontSize(double value) async {
    try {
      await SettingsService.setFontSize(value);
      state = state.copyWith(fontSize: value);
    } catch (e) {
      // Try to reinitialize SharedPreferences
      try {
        await SettingsService.reinitialize();
        await SettingsService.setFontSize(value);
        state = state.copyWith(fontSize: value);
      } catch (e2) {
        // Still update the state even if saving fails
        state = state.copyWith(fontSize: value);
      }
    }
  }

  Future<void> setQuranFontFamily(String fontFamily) async {
    try {
      await SettingsService.setQuranFontFamily(fontFamily);
      state = state.copyWith(quranFontFamily: fontFamily);
    } catch (e) {
      try {
        await SettingsService.reinitialize();
        await SettingsService.setQuranFontFamily(fontFamily);
        state = state.copyWith(quranFontFamily: fontFamily);
      } catch (e2) {
        state = state.copyWith(quranFontFamily: fontFamily);
      }
    }
  }

  Future<void> setContentFontFamily(String fontFamily) async {
    try {
      await SettingsService.setContentFontFamily(fontFamily);
      state = state.copyWith(contentFontFamily: fontFamily);
    } catch (e) {
      try {
        await SettingsService.reinitialize();
        await SettingsService.setContentFontFamily(fontFamily);
        state = state.copyWith(contentFontFamily: fontFamily);
      } catch (e2) {
        state = state.copyWith(contentFontFamily: fontFamily);
      }
    }
  }

  Future<void> setNightMode(bool nightMode) async {
    try {
      await SettingsService.setNightMode(nightMode);
      state = state.copyWith(nightMode: nightMode);
    } catch (e) {
      // Try to reinitialize SharedPreferences
      try {
        await SettingsService.reinitialize();
        await SettingsService.setNightMode(nightMode);
        state = state.copyWith(nightMode: nightMode);
      } catch (e2) {
        // Still update the state even if saving fails
        state = state.copyWith(nightMode: nightMode);
      }
    }
  }

  Future<void> resetToDefaults() async {
    await SettingsService.resetToDefaults();
    await _loadSettings();
  }
}

class SettingsState {
  final bool autoPlayAudio;
  final double fontSize;
  final bool isLoading;
  final String quranFontFamily;
  final String contentFontFamily;
  final bool nightMode;

  SettingsState({
    this.autoPlayAudio = false,
    this.fontSize = 22.0,
    this.isLoading = true,
    this.quranFontFamily = 'UthmanicHafs_V20',
    this.contentFontFamily = 'Lotus',
    this.nightMode = false,
  });

  SettingsState copyWith({
    bool? autoPlayAudio,
    double? fontSize,
    bool? isLoading,
    String? quranFontFamily,
    String? contentFontFamily,
    bool? nightMode,
  }) {
    return SettingsState(
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      fontSize: fontSize ?? this.fontSize,
      isLoading: isLoading ?? this.isLoading,
      quranFontFamily: quranFontFamily ?? this.quranFontFamily,
      contentFontFamily: contentFontFamily ?? this.contentFontFamily,
      nightMode: nightMode ?? this.nightMode,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
