import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionService {
  static const String _lastVersionKey = 'last_app_version';
  static const String _dataUpdateRequiredKey = 'data_update_required';

  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences> get _prefs async {
    if (_prefsInstance != null) {
      return _prefsInstance!;
    }
    _prefsInstance = await SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  /// Check if the app has been updated since last launch
  static Future<bool> isAppUpdated() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;
      final currentVersionCode = '$currentVersion+$currentBuildNumber';

      final prefs = await _prefs;
      final lastVersion = prefs.getString(_lastVersionKey);

      if (lastVersion == null || lastVersion != currentVersionCode) {
        // App has been updated or is running for the first time
        await prefs.setString(_lastVersionKey, currentVersionCode);
        return true;
      }

      return false;
    } catch (e) {
      // If we can't determine version, assume no update
      return false;
    }
  }

  /// Get current app version
  static Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '1.0.0';
    }
  }

  /// Get current build number
  static Future<String> getCurrentBuildNumber() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.buildNumber;
    } catch (e) {
      return '1';
    }
  }

  /// Get full version string (version + build number)
  static Future<String> getFullVersionString() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      return '1.0.0 (1)';
    }
  }

  /// Mark that data update is required
  static Future<void> setDataUpdateRequired(bool required) async {
    try {
      final prefs = await _prefs;
      await prefs.setBool(_dataUpdateRequiredKey, required);
    } catch (e) {
      // Ignore error
    }
  }

  /// Check if data update is required
  static Future<bool> isDataUpdateRequired() async {
    try {
      final prefs = await _prefs;
      return prefs.getBool(_dataUpdateRequiredKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clear data update required flag
  static Future<void> clearDataUpdateRequired() async {
    try {
      final prefs = await _prefs;
      await prefs.setBool(_dataUpdateRequiredKey, false);
    } catch (e) {
      // Ignore error
    }
  }
}
