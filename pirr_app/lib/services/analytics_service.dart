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

  /// Log user login
  Future<void> logLogin({required String loginMethod}) async {
    try {
      await _analytics.logLogin(loginMethod: loginMethod);
      debugPrint('Analytics: Login logged - $loginMethod');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log user sign up
  Future<void> logSignUp({required String signUpMethod}) async {
    try {
      await _analytics.logSignUp(signUpMethod: signUpMethod);
      debugPrint('Analytics: Sign up logged - $signUpMethod');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log entry creation
  Future<void> logEntryCreated({
    required String entryId,
    required int textLength,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'entry_created',
        parameters: {
          'entry_id': entryId,
          'text_length': textLength,
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('Analytics: Entry created logged - $entryId');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log entry deletion
  Future<void> logEntryDeleted({required String entryId}) async {
    try {
      await _analytics.logEvent(
        name: 'entry_deleted',
        parameters: {
          'entry_id': entryId,
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('Analytics: Entry deleted logged - $entryId');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log entry update
  Future<void> logEntryUpdated({
    required String entryId,
    required int textLength,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'entry_updated',
        parameters: {
          'entry_id': entryId,
          'text_length': textLength,
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('Analytics: Entry updated logged - $entryId');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log user logout
  Future<void> logLogout() async {
    try {
      await _analytics.logEvent(
        name: 'user_logout',
        parameters: {
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('Analytics: Logout logged');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log app error
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          'stack_trace': stackTrace ?? '',
          'user_id': _auth.currentUser?.uid ?? 'anonymous',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
      debugPrint('Analytics: Error logged - $errorType');
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  /// Log feature usage
  Future<void> logFeatureUsage({
    required String featureName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final eventParameters = {
        'feature_name': featureName,
        'user_id': _auth.currentUser?.uid ?? 'anonymous',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?parameters,
      };

      await _analytics.logEvent(
        name: 'feature_usage',
        parameters: eventParameters.map(
          (key, value) => MapEntry(key, value as Object),
        ),
      );
      debugPrint('Analytics: Feature usage logged - $featureName');
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
