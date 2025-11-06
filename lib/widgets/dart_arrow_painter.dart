import 'package:flutter/material.dart';

/// Draws a dart arrow from behind view (flight visible)
class DartArrowPainter extends CustomPainter {
  final Color flightColor;
  final Color barrelColor;

  DartArrowPainter({
    this.flightColor = Colors.yellow,
    this.barrelColor = Colors.black,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw flight (4 triangular fins)
    final flightPaint = Paint()
      ..color = flightColor
      ..style = PaintingStyle.fill;

    final flightStrokePaint = Paint()
      ..color = barrelColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Top fin
    final topFin = Path()
      ..moveTo(centerX, centerY - size.height * 0.4)
      ..lineTo(centerX - size.width * 0.15, centerY)
      ..lineTo(centerX + size.width * 0.15, centerY)
      ..close();
    canvas.drawPath(topFin, flightPaint);
    canvas.drawPath(topFin, flightStrokePaint);

    // Right fin
    final rightFin = Path()
      ..moveTo(centerX + size.width * 0.4, centerY)
      ..lineTo(centerX, centerY - size.height * 0.15)
      ..lineTo(centerX, centerY + size.height * 0.15)
      ..close();
    canvas.drawPath(rightFin, flightPaint);
    canvas.drawPath(rightFin, flightStrokePaint);

    // Bottom fin
    final bottomFin = Path()
      ..moveTo(centerX, centerY + size.height * 0.4)
      ..lineTo(centerX + size.width * 0.15, centerY)
      ..lineTo(centerX - size.width * 0.15, centerY)
      ..close();
    canvas.drawPath(bottomFin, flightPaint);
    canvas.drawPath(bottomFin, flightStrokePaint);

    // Left fin
    final leftFin = Path()
      ..moveTo(centerX - size.width * 0.4, centerY)
      ..lineTo(centerX, centerY + size.height * 0.15)
      ..lineTo(centerX, centerY - size.height * 0.15)
      ..close();
    canvas.drawPath(leftFin, flightPaint);
    canvas.drawPath(leftFin, flightStrokePaint);

    // Draw barrel (center circle)
    final barrelPaint = Paint()
      ..color = barrelColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), size.width * 0.12, barrelPaint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX - size.width * 0.03, centerY - size.height * 0.03),
      size.width * 0.05,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(DartArrowPainter oldDelegate) => false;
}

/// Widget wrapper for dart arrow
class DartArrowWidget extends StatelessWidget {
  final double size;
  final Color flightColor;

  const DartArrowWidget({
    super.key,
    this.size = 30,
    this.flightColor = Colors.yellow,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: DartArrowPainter(flightColor: flightColor),
    );
  }
}

