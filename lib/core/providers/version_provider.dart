import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_azkar_app/core/services/version_service.dart';
import 'package:new_azkar_app/core/services/isar_services.dart';

final versionProvider = FutureProvider<String>((ref) async {
  return await VersionService.getFullVersionString();
});

final appUpdateCheckProvider = FutureProvider<bool>((ref) async {
  return await VersionService.isAppUpdated();
});

final dataUpdateProvider =
    StateNotifierProvider<DataUpdateNotifier, AsyncValue<void>>((ref) {
      return DataUpdateNotifier();
    });

class DataUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  DataUpdateNotifier() : super(const AsyncValue.data(null));

  Future<void> updateData() async {
    state = const AsyncValue.loading();
    try {
      final isarServices = IsarServices();
      await isarServices.updateAzkarData();
      await VersionService.clearDataUpdateRequired();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> checkAndUpdateIfRequired() async {
    try {
      final isUpdated = await VersionService.isAppUpdated();
      if (isUpdated) {
        await VersionService.setDataUpdateRequired(true);
        // Automatically update data when app is updated
        await updateData();
      }
    } catch (e) {
      // Ignore error, user can manually update if needed
    }
  }
}
