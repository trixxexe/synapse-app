import 'package:flutter/material.dart';
import '../config/theme.dart';

/// ScoreBackgroundPainter
/// 
/// Custom painter that renders a dynamic gradient background.
/// The color palette shifts based on the Synapse Score:
/// - High score (70-100): Cool cyan/purple tones (optimal state)
/// - Medium score (40-70): Warm amber/teal tones (moderate state)
/// - Low score (0-40): Deep red/orange tones (needs attention)
/// 
/// Includes subtle animated mesh-like patterns for visual depth.
class ScoreBackgroundPainter extends CustomPainter {
  final double score;
  final Animation<double>? animation;

  ScoreBackgroundPainter({
    required this.score,
    this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Determine color palette based on score
    final (primaryColor, secondaryColor, tertiaryColor) = _getScoreColors(score);

    // Base gradient
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primaryColor,
        secondaryColor,
        tertiaryColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Subtle radial glow at center
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.6;
    final radialGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.6,
      colors: [
        primaryColor.withOpacity(0.15),
        Colors.transparent,
      ],
    );

    paint.shader = radialGradient.createShader(rect);
    canvas.drawCircle(center, radius, paint);

    // Draw subtle mesh nodes for depth
    _drawMeshNodes(canvas, size, primaryColor);
  }

  /// Map score to color palette
  (Color, Color, Color) _getScoreColors(double score) {
    if (score >= 70) {
      // High energy: cyan -> purple -> deep blue
      return (
        const Color(0xFF0A0E17),
        SynapseTheme.accentPrimary.withOpacity(0.12),
        SynapseTheme.accentSecondary.withOpacity(0.08),
      );
    } else if (score >= 40) {
      // Moderate: warm amber -> teal -> dark
      return (
        const Color(0xFF0A0E17),
        SynapseTheme.accentWarning.withOpacity(0.10),
        const Color(0xFF00F5D4).withOpacity(0.06),
      );
    } else {
      // Low: deep red -> orange -> dark
      return (
        const Color(0xFF0A0E17),
        SynapseTheme.accentDanger.withOpacity(0.12),
        SynapseTheme.accentWarning.withOpacity(0.06),
      );
    }
  }

  /// Draw subtle geometric mesh nodes for visual depth
  void _drawMeshNodes(Canvas canvas, Size size, Color accentColor) {
    final nodePaint = Paint()
      ..color = accentColor.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final nodePositions = _generateNodePositions(size);

    // Draw connecting lines
    for (int i = 0; i < nodePositions.length; i++) {
      for (int j = i + 1; j < nodePositions.length; j++) {
        final distance = (nodePositions[i] - nodePositions[j]).distance;
        if (distance < size.width * 0.35) {
          canvas.drawLine(nodePositions[i], nodePositions[j], nodePaint);
        }
      }
    }

    // Draw nodes
    final dotPaint = Paint()
      ..color = accentColor.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    for (final position in nodePositions) {
      canvas.drawCircle(position, 2.0, dotPaint);
    }
  }

  /// Generate deterministic node positions based on screen size
  List<Offset> _generateNodePositions(Size size) {
    final nodes = <Offset>[];
    final spacing = size.width / 5;

    for (int x = 1; x <= 4; x++) {
      for (int y = 1; y <= 4; y++) {
        // Add slight offset for organic feel
        final offsetX = (x % 2 == 0) ? spacing * 0.15 : -spacing * 0.15;
        final offsetY = (y % 2 == 0) ? spacing * 0.1 : -spacing * 0.1;

        nodes.add(Offset(
          x * spacing + offsetX,
          y * spacing + offsetY,
        ));
      }
    }

    return nodes;
  }

  @override
  bool shouldRepaint(ScoreBackgroundPainter oldDelegate) {
    // Repaint when score changes (threshold to avoid excessive repaints)
    return (oldDelegate.score - score).abs() > 0.01;
  }
}
