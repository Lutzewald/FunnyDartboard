import 'package:flutter/material.dart';
import 'dart:math';

/// Draws chalk-style tick marks (like on a chalkboard)
class ChalkTickPainter extends CustomPainter {
  final int tickCount;
  final Color chalkColor;

  ChalkTickPainter({required this.tickCount, this.chalkColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = chalkColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final spacing = 8.0;
    final tickHeight = 16.0;
    final tickAngle = 15 * pi / 180; // Slight angle for hand-drawn look

    for (int i = 0; i < tickCount && i < 5; i++) {
      final x = i * spacing;

      // Every 5th tick is crossed (||||/)
      if (i == 4) {
        // Draw diagonal cross line through the 4 previous ticks
        canvas.drawLine(Offset(-2, tickHeight), Offset(x + 2, 0), paint);
      } else {
        // Draw vertical tick with slight angle
        final startY = tickHeight;
        final endY = 0.0;
        final startX = x + sin(tickAngle) * tickHeight;
        final endX = x;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      }
    }
  }

  @override
  bool shouldRepaint(ChalkTickPainter oldDelegate) {
    return oldDelegate.tickCount != tickCount;
  }
}

/// Widget wrapper for chalk ticks
class ChalkTicks extends StatelessWidget {
  final int count;
  final Color color;

  const ChalkTicks({super.key, required this.count, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 20),
      painter: ChalkTickPainter(tickCount: count, chalkColor: color),
    );
  }
}

