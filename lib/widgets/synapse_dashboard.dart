import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../controllers/synapse_score_controller.dart';
import 'score_background_painter.dart';

/// SynapseDashboard
/// 
/// The primary dashboard widget displaying:
/// - Dynamic CustomPainter background that shifts colors based on Synapse Score
/// - Real-time Energy and Focus level indicators
/// - High-impact Focus Shield toggle button
/// - Sync controls for biometric data
/// 
/// Built with Riverpod for reactive state management.
class SynapseDashboard extends ConsumerWidget {
  const SynapseDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(synapseScoreController);
    final controller = ref.read(synapseScoreController.notifier);

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic background painter
          CustomPaint(
            painter: ScoreBackgroundPainter(score: state.synapseScore),
            child: Container(),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context),
                  const SizedBox(height: 32),

                  // Synapse Score display
                  _buildScoreDisplay(context, state.synapseScore),
                  const SizedBox(height: 32),

                  // Energy and Focus gauges
                  Row(
                    children: [
                      Expanded(
                        child: _buildGaugeCard(
                          context,
                          label: 'ENERGY',
                          value: state.energyLevel,
                          icon: Icons.bolt_rounded,
                          color: SynapseTheme.accentPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGaugeCard(
                          context,
                          label: 'FOCUS',
                          value: state.focusLevel,
                          icon: Icons.center_focus_strong_rounded,
                          color: SynapseTheme.accentSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Last sync info
                  _buildSyncInfo(context, state.lastSyncTime),
                  const Spacer(),

                  // Focus Shield toggle (high-impact button)
                  _buildShieldToggle(context, state.isShieldActive, controller),
                  const SizedBox(height: 16),

                  // Sync button
                  _buildSyncButton(context, controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Header with app branding
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: SynapseTheme.accentGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.psychology_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          'SYNAPSE',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                letterSpacing: 2.0,
              ),
        ),
      ],
    );
  }

  /// Large circular score display
  Widget _buildScoreDisplay(BuildContext context, double score) {
    final scoreColor = _getScoreColor(score);

    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Inner score text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: scoreColor,
                          ),
                    ),
                    Text(
                      'SYNAPSE SCORE',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: SynapseTheme.textSecondary,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getScoreLabel(score),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  /// Individual metric gauge card
  Widget _buildGaugeCard(
    BuildContext context, {
    required String label,
    required double value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: SynapseTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3550)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SynapseTheme.textSecondary,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(value * 100).toInt()}%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontSize: 32,
                ),
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  /// Last sync timestamp display
  Widget _buildSyncInfo(BuildContext context, DateTime lastSync) {
    final timeAgo = _getTimeAgo(lastSync);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(
            Icons.sync_rounded,
            size: 16,
            color: SynapseTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Last synced: $timeAgo',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// High-impact Focus Shield toggle button
  Widget _buildShieldToggle(
    BuildContext context,
    bool isActive,
    SynapseScoreController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => controller.toggleShield(),
        icon: Icon(
          isActive ? Icons.shield_rounded : Icons.shield_outlined,
          size: 24,
        ),
        label: Text(
          isActive ? 'SHIELD ACTIVE' : 'ACTIVATE FOCUS SHIELD',
          style: const TextStyle(fontSize: 16, letterSpacing: 1.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? SynapseTheme.accentPrimary
              : Colors.transparent,
          foregroundColor: isActive
              ? const Color(0xFF0A0E17)
              : SynapseTheme.accentPrimary,
          side: isActive
              ? null
              : const BorderSide(color: SynapseTheme.accentPrimary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  /// Biometric sync button
  Widget _buildSyncButton(BuildContext context, SynapseScoreController controller) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => controller.syncBiometrics(),
        icon: const Icon(Icons.health_and_safety_rounded, size: 20),
        label: const Text('Sync Health Data'),
        style: OutlinedButton.styleFrom(
          foregroundColor: SynapseTheme.textSecondary,
          side: const BorderSide(color: Color(0xFF2A3550)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Color mapping for score states
  Color _getScoreColor(double score) {
    if (score >= 70) return SynapseTheme.accentPrimary;
    if (score >= 40) return SynapseTheme.accentWarning;
    return SynapseTheme.accentDanger;
  }

  /// Human-readable score label
  String _getScoreLabel(double score) {
    if (score >= 85) return 'OPTIMAL STATE';
    if (score >= 70) return 'IN FLOW';
    if (score >= 55) return 'MODERATE';
    if (score >= 40) return 'FATIGUED';
    return 'NEEDS RECOVERY';
  }

  /// Human-readable time ago string
  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
