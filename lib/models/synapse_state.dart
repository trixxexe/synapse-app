import 'package:flutter/foundation.dart';

/// Immutable state model representing the user's current
/// biometric and cognitive readiness levels.
@immutable
class SynapseState {
  /// Energy level derived from heart rate variability, sleep data, and activity (0.0 - 1.0)
  final double energyLevel;

  /// Focus level derived from screen time patterns and notification density (0.0 - 1.0)
  final double focusLevel;

  /// Whether the Focus Shield (DND mediation) is currently active
  final bool isShieldActive;

  /// Timestamp of the last biometric sync
  final DateTime lastSyncTime;

  const SynapseState({
    this.energyLevel = 0.5,
    this.focusLevel = 0.5,
    this.isShieldActive = false,
    required this.lastSyncTime,
  });

  /// Factory constructor that defaults lastSyncTime to now
  factory SynapseState.now({
    double energyLevel = 0.5,
    double focusLevel = 0.5,
    bool isShieldActive = false,
  }) {
    return SynapseState(
      energyLevel: energyLevel,
      focusLevel: focusLevel,
      isShieldActive: isShieldActive,
      lastSyncTime: DateTime.now(),
    );
  }

  /// Create a copy with modified fields (immutable update pattern)
  SynapseState copyWith({
    double? energyLevel,
    double? focusLevel,
    bool? isShieldActive,
    DateTime? lastSyncTime,
  }) {
    return SynapseState(
      energyLevel: energyLevel ?? this.energyLevel,
      focusLevel: focusLevel ?? this.focusLevel,
      isShieldActive: isShieldActive ?? this.isShieldActive,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  /// Compute the composite Synapse Score (0 - 100)
  /// Weighted average: Energy 40%, Focus 60%
  double get synapseScore => ((energyLevel * 0.4) + (focusLevel * 0.6)) * 100;

  @override
  String toString() => 'SynapseState(energy: ${energyLevel.toStringAsFixed(2)}, '
      'focus: ${focusLevel.toStringAsFixed(2)}, shield: $isShieldActive)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SynapseState &&
          runtimeType == other.runtimeType &&
          energyLevel == other.energyLevel &&
          focusLevel == other.focusLevel &&
          isShieldActive == other.isShieldActive &&
          lastSyncTime == other.lastSyncTime;

  @override
  int get hashCode => Object.hash(
        energyLevel,
        focusLevel,
        isShieldActive,
        lastSyncTime,
      );
}
