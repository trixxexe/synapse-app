import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

/// Privacy-first biometric data service.
/// 
/// Handles secure integration with Apple HealthKit and Google Health Connect.
/// All data is processed locally; no biometric data is transmitted externally.
class BiometricSyncService {
  final Health _health = Health();

  // Types of health data we read for energy calculation
  static const List<HealthDataType> _readTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.STEPS,
    HealthDataType.RESTING_HEART_RATE,
  ];

  /// Request platform-specific health permissions.
  /// Returns true if at least one permission was granted.
  Future<bool> requestPermissions() async {
    // Request general health permission on Android
    final bool hasPermission = await _health.hasPermissions(_readTypes);
    if (hasPermission) return true;

    try {
      final bool granted = await _health.requestAuthorization(_readTypes);
      debugPrint('[BiometricSync] Permission request result: $granted');
      return granted;
    } catch (e) {
      debugPrint('[BiometricSync] Permission error: $e');
      return false;
    }
  }

  /// Fetch aggregated health metrics from the last 24 hours.
  /// Returns a map of normalized values (0.0 - 1.0) for energy calculation.
  Future<Map<String, double>> fetchBiometricSnapshot() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    final Map<String, double> metrics = {};

    try {
      // Fetch heart rate data
      final heartRateData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.HEART_RATE],
      );

      if (heartRateData.isNotEmpty) {
        final avgHR = heartRateData
            .where((d) => d.value is num)
            .map((d) => (d.value as num).toDouble())
            .reduce((a, b) => a + b) / heartRateData.length;

        // Normalize: 60-100 BPM maps to 1.0-0.0 (lower resting HR = higher energy)
        metrics['heartRate'] = _clamp((100 - avgHR) / 40, 0.0, 1.0);
      }

      // Fetch sleep data
      final sleepData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.SLEEP_ASLEEP],
      );

      if (sleepData.isNotEmpty) {
        final totalSleepMinutes = sleepData
            .where((d) => d.value is num)
            .map((d) => (d.value as num).toDouble())
            .reduce((a, b) => a + b) / 60; // Convert seconds to minutes

        // Normalize: 7-9 hours maps to 0.0-1.0
        metrics['sleep'] = _clamp((totalSleepMinutes - 420) / 120, 0.0, 1.0);
      }

      // Fetch step count for activity level
      final stepData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.STEPS],
      );

      if (stepData.isNotEmpty) {
        final totalSteps = stepData
            .where((d) => d.value is num)
            .map((d) => (d.value as num).toDouble())
            .reduce((a, b) => a + b);

        // Normalize: 0-10000 steps maps to 0.0-1.0
        metrics['activity'] = _clamp(totalSteps / 10000, 0.0, 1.0);
      }

      debugPrint('[BiometricSync] Snapshot collected: $metrics');
      return metrics;
    } catch (e) {
      debugPrint('[BiometricSync] Fetch error: $e');
      return {};
    }
  }

  /// Compute energy level from biometric metrics.
  /// Weighted: Sleep 50%, Heart Rate 30%, Activity 20%
  double computeEnergyLevel(Map<String, double> metrics) {
    final sleep = metrics['sleep'] ?? 0.5;
    final heartRate = metrics['heartRate'] ?? 0.5;
    final activity = metrics['activity'] ?? 0.5;

    return (sleep * 0.5) + (heartRate * 0.3) + (activity * 0.2);
  }

  /// Utility: Clamp a value between min and max
  double _clamp(double value, double min, double max) {
    return value < min ? min : (value > max ? max : value);
  }

  /// Revoke all health permissions (privacy compliance)
  Future<void> revokePermissions() async {
    try {
      await _health.revokePermissions();
      debugPrint('[BiometricSync] Permissions revoked');
    } catch (e) {
      debugPrint('[BiometricSync] Revoke error: $e');
    }
  }
}
