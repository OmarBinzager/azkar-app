import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reciter.dart';

const String _kSelectedReciterKey = 'selected_quran_reciter_identifier';

class QuranReciterNotifier extends StateNotifier<QuranReciter> {
  QuranReciterNotifier() : super(defaultQuranReciters.first) {
    _loadSavedReciter();
  }

  Future<void> _loadSavedReciter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_kSelectedReciterKey);
      if (savedId != null && savedId.isNotEmpty) {
        final match = defaultQuranReciters.firstWhere(
          (r) => r.identifier == savedId,
          orElse: () => defaultQuranReciters.first,
        );
        state = match;
      }
    } catch (e) {
      print('Error loading saved Quran reciter: $e');
    }
  }

  Future<void> selectReciter(QuranReciter reciter) async {
    state = reciter;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSelectedReciterKey, reciter.identifier);
    } catch (e) {
      print('Error saving Quran reciter: $e');
    }
  }
}

final quranReciterProvider =
    StateNotifierProvider<QuranReciterNotifier, QuranReciter>((ref) {
  return QuranReciterNotifier();
});
