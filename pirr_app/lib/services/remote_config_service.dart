import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Service class for managing Firebase Remote Config
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// Initialize Remote Config with default values
  Future<void> initialize() async {
    // Set default values
    await _remoteConfig.setDefaults({
      'showDateChip': true,
      'maxEntryLength': 1000,
    });

    // Configure settings for development
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config fetch failed: $e');
    }
  }

  /// Get boolean value from Remote Config
  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  /// Get integer value from Remote Config
  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  /// Check if date chip should be shown
  bool get showDateChip => getBool('showDateChip');

  /// Get maximum entry length
  int get maxEntryLength => getInt('maxEntryLength');

  /// Force fetch and activate new values
  Future<bool> fetchAndActivate() async {
    try {
      return await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config fetch failed: $e');
      return false;
    }
  }
}
