import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service class for managing Firebase Analytics events
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('Analytics: Screen view logged - $screenName');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Generic event logging with automatic user context and timestamp
  Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final eventParameters = {
        'user_id': _auth.currentUser?.uid ?? 'anonymous',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?parameters,
      };

      await _analytics.logEvent(
        name: eventName,
        parameters: eventParameters.map(
          (key, value) => MapEntry(key, value as Object),
        ),
      );
      debugPrint('Analytics: Event logged - $eventName');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Set user properties
  Future<void> setUserProperties({String? userType, String? appVersion}) async {
    try {
      if (userType != null) {
        await _analytics.setUserProperty(name: 'user_type', value: userType);
      }
      if (appVersion != null) {
        await _analytics.setUserProperty(
          name: 'app_version',
          value: appVersion,
        );
      }
      debugPrint('Analytics: User properties set');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}
