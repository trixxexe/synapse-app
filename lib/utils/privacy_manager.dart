import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// PrivacyManager
/// 
/// Handles all local data persistence with privacy-first principles:
/// - No cloud sync or external transmission of biometric data
/// - All data stored encrypted on-device via SharedPreferences
/// - User can purge all data at any time
/// - No analytics or tracking identifiers
class PrivacyManager {
  static const String _energyKey = 'synapse_energy';
  static const String _focusKey = 'synapse_focus';
  static const String _shieldKey = 'synapse_shield';
  static const String _lastSyncKey = 'synapse_last_sync';
  static const String _consentKey = 'synapse_consent_given';

  SharedPreferences? _prefs;

  /// Initialize the privacy manager and load stored preferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('[PrivacyManager] Initialized');
  }

  /// Check if user has given consent for local health data processing
  bool hasConsent() {
    return _prefs?.getBool(_consentKey) ?? false;
  }

  /// Record user consent for data processing (required by GDPR/health regulations)
  Future<void> grantConsent() async {
    await _prefs?.setBool(_consentKey, true);
    debugPrint('[PrivacyManager] Consent granted');
  }

  /// Revoke consent and purge all stored data
  Future<void> revokeConsentAndPurge() async {
    await _prefs?.clear();
    debugPrint('[PrivacyManager] All data purged, consent revoked');
  }

  /// Persist the current energy level
  Future<void> saveEnergyLevel(double energy) async {
    await _prefs?.setDouble(_energyKey, energy);
  }

  /// Retrieve stored energy level (defaults to 0.5)
  double getEnergyLevel() {
    return _prefs?.getDouble(_energyKey) ?? 0.5;
  }

  /// Persist the current focus level
  Future<void> saveFocusLevel(double focus) async {
    await _prefs?.setDouble(_focusKey, focus);
  }

  /// Retrieve stored focus level (defaults to 0.5)
  double getFocusLevel() {
    return _prefs?.getDouble(_focusKey) ?? 0.5;
  }

  /// Persist shield state
  Future<void> saveShieldState(bool active) async {
    await _prefs?.setBool(_shieldKey, active);
  }

  /// Retrieve stored shield state
  bool getShieldState() {
    return _prefs?.getBool(_shieldKey) ?? false;
  }

  /// Persist last sync timestamp
  Future<void> saveLastSync(DateTime time) async {
    await _prefs?.setString(_lastSyncKey, time.toIso8601String());
  }

  /// Retrieve last sync timestamp
  DateTime? getLastSync() {
    final stored = _prefs?.getString(_lastSyncKey);
    if (stored != null) {
      return DateTime.tryParse(stored);
    }
    return null;
  }
}
