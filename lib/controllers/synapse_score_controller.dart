import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/synapse_state.dart';
import '../services/biometric_sync_service.dart';
import '../services/notification_mediator_service.dart';
import '../utils/privacy_manager.dart';

/// Provider for the BiometricSyncService (singleton)
final biometricServiceProvider = Provider<BiometricSyncService>((ref) {
  return BiometricSyncService();
});

/// Provider for the NotificationMediatorService (singleton)
final notificationMediatorProvider = Provider<NotificationMediatorService>((ref) {
  final service = NotificationMediatorService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the PrivacyManager (singleton)
final privacyManagerProvider = Provider<PrivacyManager>((ref) {
  return PrivacyManager();
});

/// SynapseScoreController
///
/// Central state controller that manages the SynapseState using Riverpod.
/// Handles:
/// - Biometric data fetching and energy computation
/// - Focus level tracking based on shield state and time patterns
/// - Focus Shield toggle with side effects
/// - Privacy-aware data persistence
final synapseScoreController =
    StateNotifierProvider<SynapseScoreController, SynapseState>((ref) {
  return SynapseScoreController(
    biometricService: ref.watch(biometricServiceProvider),
    notificationService: ref.watch(notificationMediatorProvider),
    privacyManager: ref.watch(privacyManagerProvider),
  );
});

class SynapseScoreController extends StateNotifier<SynapseState> {
  final BiometricSyncService _biometricService;
  final NotificationMediatorService _notificationService;
  final PrivacyManager _privacyManager;

  SynapseScoreController({
    required BiometricSyncService biometricService,
    required NotificationMediatorService notificationService,
    required PrivacyManager privacyManager,
  })  : _biometricService = biometricService,
        _notificationService = notificationService,
        _privacyManager = privacyManager,
        super(const SynapseState()) {
    _restoreState();
  }

  /// Restore previously saved state from local storage
  void _restoreState() {
    final energy = _privacyManager.getEnergyLevel();
    final focus = _privacyManager.getFocusLevel();
    final shield = _privacyManager.getShieldState();
    final lastSync = _privacyManager.getLastSync();

    state = SynapseState(
      energyLevel: energy,
      focusLevel: focus,
      isShieldActive: shield,
      lastSyncTime: lastSync ?? DateTime.now(),
    );
  }

  /// Sync biometric data from HealthKit/Health Connect and update energy level
  Future<void> syncBiometrics() async {
    // Privacy gate: only proceed if user has given consent
    if (!_privacyManager.hasConsent()) {
      return;
    }

    final hasPermission = await _biometricService.requestPermissions();
    if (!hasPermission) return;

    final metrics = await _biometricService.fetchBiometricSnapshot();
    final energyLevel = _biometricService.computeEnergyLevel(metrics);

    state = state.copyWith(
      energyLevel: energyLevel,
      lastSyncTime: DateTime.now(),
    );

    // Persist to local storage
    await _privacyManager.saveEnergyLevel(energyLevel);
    await _privacyManager.saveLastSync(state.lastSyncTime);
  }

  /// Update focus level based on user activity patterns
  /// Called periodically or when significant events occur
  Future<void> updateFocusLevel(double newFocus) async {
    state = state.copyWith(
      focusLevel: newFocus.clamp(0.0, 1.0),
    );
    await _privacyManager.saveFocusLevel(state.focusLevel);
  }

  /// Toggle the Focus Shield (DND mediation layer)
  Future<void> toggleShield() async {
    final newState = !state.isShieldActive;

    if (newState) {
      await _notificationService.activateShield();
      // Activating shield boosts focus by reducing distractions
      state = state.copyWith(
        isShieldActive: true,
        focusLevel: (state.focusLevel + 0.15).clamp(0.0, 1.0),
      );
    } else {
      await _notificationService.deactivateShield();
      state = state.copyWith(isShieldActive: false);
    }

    await _privacyManager.saveShieldState(state.isShieldActive);
    await _privacyManager.saveFocusLevel(state.focusLevel);
  }

  /// Grant consent for local health data processing
  Future<void> grantConsent() async {
    await _privacyManager.grantConsent();
  }

  /// Revoke consent and purge all data
  Future<void> revokeConsent() async {
    await _privacyManager.revokeConsentAndPurge();
    state = const SynapseState();
  }
}
