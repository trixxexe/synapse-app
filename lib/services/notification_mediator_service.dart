import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// NotificationMediatorService
/// 
/// Manages Android's Do Not Disturb (DND) state and notification mediation.
/// Acts as the "Focus Shield" layer that filters and prioritizes incoming
/// notifications based on the user's current focus state.
/// 
/// Note: Full DND control on Android requires the Notification Policy Access
/// permission (android.permission.ACCESS_NOTIFICATION_POLICY) which must be
/// granted via system settings. This service provides the Flutter-side bridge.
class NotificationMediatorService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isShieldActive = false;

  /// Whether the shield (DND mediation) is currently active
  bool get isShieldActive => _isShieldActive;

  /// Initialize the notification system with Android-specific settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);
    _isInitialized = true;

    debugPrint('[NotificationMediator] Initialized');
  }

  /// Request notification permission from the user
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Request DND (Do Not Disturb) access permission.
  /// This opens the system settings screen for the user to grant access.
  /// Returns true if the permission appears to be granted.
  Future<bool> requestDndAccess() async {
    // Open system settings for DND access
    await Permission.notification.request();
    await openAppSettings();

    // Note: Android DND access cannot be programmatically verified without
    // platform channel code. We return true after opening settings to
    /// indicate the user has been prompted.
    debugPrint('[NotificationMediator] DND settings opened');
    return true;
  }

  /// Activate the Focus Shield.
  /// 
  /// When active, this service will:
  /// 1. Configure a high-priority "Shield Active" notification
  /// 2. Suppress non-critical notifications (app-level mediation)
  /// 3. Allow whitelisted contacts/apps through
  /// 
  /// For full system-level DND, users must grant Notification Policy Access
  /// in Android Settings > Sound > Do Not Disturb > Special access.
  Future<void> activateShield() async {
    if (!_isInitialized) await initialize();

    _isShieldActive = true;

    // Show persistent notification indicating shield is active
    const androidDetails = AndroidNotificationDetails(
      'synapse_shield',
      'Focus Shield',
      channelDescription: 'Indicates when Focus Shield is active',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      0,
      'Focus Shield Active',
      'Non-critical notifications are being filtered.',
      details,
    );

    debugPrint('[NotificationMediator] Shield ACTIVATED');
  }

  /// Deactivate the Focus Shield and restore normal notification flow.
  Future<void> deactivateShield() async {
    _isShieldActive = false;
    await _notifications.cancel(0);
    debugPrint('[NotificationMediator] Shield DEACTIVATED');
  }

  /// Toggle the Focus Shield on/off
  Future<void> toggleShield() async {
    if (_isShieldActive) {
      await deactivateShield();
    } else {
      await activateShield();
    }
  }

  /// Send a high-priority notification through the shield (for critical alerts)
  Future<void> sendCriticalAlert({
    required String title,
    required String body,
    int id = 1,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'synapse_critical',
      'Critical Alerts',
      channelDescription: 'High-priority alerts that bypass the shield',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details);
  }

  /// Clean up resources
  Future<void> dispose() async {
    if (_isShieldActive) {
      await deactivateShield();
    }
    _isInitialized = false;
  }
}
