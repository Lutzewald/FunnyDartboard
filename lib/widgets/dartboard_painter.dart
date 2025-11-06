import 'package:flutter/material.dart';
import 'dart:math';

/// Custom painter for drawing the dartboard
class DartboardPainter extends CustomPainter {
  final List<dynamic> arrows;

  DartboardPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw dartboard rings
    _drawRings(canvas, center, radius);

    // Draw dartboard sectors
    _drawSectors(canvas, center, radius);

    // Draw numbers
    _drawNumbers(canvas, center, radius);

    // Draw arrows
    _drawArrows(canvas, center, radius);
  }

  void _drawRings(Canvas canvas, Offset center, double radius) {
    // Outer board
    final outerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerPaint);

    // Wire frame
    final wirePaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Triple ring
    canvas.drawCircle(center, radius * 0.635, wirePaint);
    canvas.drawCircle(center, radius * 0.565, wirePaint);

    // Double ring
    canvas.drawCircle(center, radius * 1.0, wirePaint);
    canvas.drawCircle(center, radius * 0.932, wirePaint);

    // Bullseye rings
    canvas.drawCircle(center, radius * 0.1, wirePaint);
    canvas.drawCircle(center, radius * 0.038, wirePaint);
  }

  void _drawSectors(Canvas canvas, Offset center, double radius) {
    const sectorAngle = 18.0;

    for (int i = 0; i < 20; i++) {
      final startAngle = (i * sectorAngle - 9) * pi / 180;
      final sweepAngle = sectorAngle * pi / 180;

      // Alternate colors (black and white/cream)
      final color = i % 2 == 0 ? Colors.black : Colors.grey.shade300;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Draw outer sector (between double and triple)
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius * 1.0),
          startAngle,
          sweepAngle,
          false,
        )
        ..lineTo(center.dx, center.dy)
        ..close();
      canvas.drawPath(path, paint);

      // Draw triple ring
      final tripleColor = i % 2 == 0
          ? Colors.red.shade900
          : Colors.green.shade700;
      final triplePaint = Paint()..color = tripleColor;
      final triplePath = Path();
      final tripleOuter = radius * 0.635;
      final tripleInner = radius * 0.565;

      triplePath.arcTo(
        Rect.fromCircle(center: center, radius: tripleOuter),
        startAngle,
        sweepAngle,
        false,
      );

      final endPoint = Offset(
        center.dx + tripleInner * cos(startAngle + sweepAngle),
        center.dy + tripleInner * sin(startAngle + sweepAngle),
      );
      triplePath.lineTo(endPoint.dx, endPoint.dy);

      triplePath.arcTo(
        Rect.fromCircle(center: center, radius: tripleInner),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      triplePath.close();
      canvas.drawPath(triplePath, triplePaint);

      // Draw double ring
      final doubleColor = i % 2 == 0
          ? Colors.red.shade900
          : Colors.green.shade700;
      final doublePaint = Paint()..color = doubleColor;
      final doublePath = Path();
      final doubleOuter = radius * 1.0;
      final doubleInner = radius * 0.932;

      doublePath.arcTo(
        Rect.fromCircle(center: center, radius: doubleOuter),
        startAngle,
        sweepAngle,
        false,
      );

      final endPoint2 = Offset(
        center.dx + doubleInner * cos(startAngle + sweepAngle),
        center.dy + doubleInner * sin(startAngle + sweepAngle),
      );
      doublePath.lineTo(endPoint2.dx, endPoint2.dy);

      doublePath.arcTo(
        Rect.fromCircle(center: center, radius: doubleInner),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      doublePath.close();
      canvas.drawPath(doublePath, doublePaint);
    }

    // Draw bullseye
    final bullPaint = Paint()..color = Colors.green.shade700;
    canvas.drawCircle(center, radius * 0.1, bullPaint);

    final innerBullPaint = Paint()..color = Colors.red.shade900;
    canvas.drawCircle(center, radius * 0.038, innerBullPaint);
  }

  void _drawNumbers(Canvas canvas, Offset center, double radius) {
    // Correct dartboard number arrangement (clockwise from top)
    // 20 1 18 4 13 6 10 15 2 17 3 19 7 16 8 11 14 9 12 5
    const fields = [
      20, // Top (0°)
      1,
      18,
      4,
      13,
      6,
      10,
      15,
      2,
      17,
      3,
      19,
      7,
      16,
      8,
      11,
      14,
      9,
      12,
      5,
    ];
    const sectorAngle = 18.0;

    for (int i = 0; i < 20; i++) {
      // Numbers centered at i * 18 degrees (0° = top, clockwise)
      final angle = (i * sectorAngle) * pi / 180;
      // Position numbers in the large single-scoring area (between triple and double rings)
      final textRadius = radius * 0.78;

      // Convert angle to position (0° is up, clockwise)
      final x = center.dx + textRadius * sin(angle);
      final y = center.dy - textRadius * cos(angle);

      // Determine segment color (alternating black/white)
      final isBlackSegment = i % 2 == 0;

      // Draw text with contrasting stroke for visibility
      final textStyle = TextStyle(
        color: isBlackSegment ? Colors.white : Colors.black,
        fontSize: radius * 0.12,
        fontWeight: FontWeight.bold,
      );

      // Draw stroke/outline first
      final strokeTextSpan = TextSpan(
        text: '${fields[i]}',
        style: textStyle.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = isBlackSegment ? Colors.black : Colors.white,
        ),
      );

      final strokePainter = TextPainter(
        text: strokeTextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      strokePainter.layout();
      strokePainter.paint(
        canvas,
        Offset(x - strokePainter.width / 2, y - strokePainter.height / 2),
      );

      // Draw filled text on top
      final textSpan = TextSpan(text: '${fields[i]}', style: textStyle);

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawArrows(Canvas canvas, Offset center, double radius) {
    for (var arrow in arrows) {
      if (arrow != null) {
        final arrowX = center.dx + (arrow.getX() - 0.5) * radius * 2;
        final arrowY = center.dy + (arrow.getY() - 0.5) * radius * 2;

        // Draw dart arrow from behind (with flight visible)
        _drawDartArrow(canvas, Offset(arrowX, arrowY), radius * 0.06);
      }
    }
  }

  void _drawDartArrow(Canvas canvas, Offset position, double size) {
    // Draw flight (4 triangular fins)
    final flightPaint = Paint()
      ..color = Colors.yellow.shade700
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Top fin
    final topFin = Path()
      ..moveTo(position.dx, position.dy - size * 0.8)
      ..lineTo(position.dx - size * 0.3, position.dy)
      ..lineTo(position.dx + size * 0.3, position.dy)
      ..close();
    canvas.drawPath(topFin, flightPaint);
    canvas.drawPath(topFin, strokePaint);

    // Right fin
    final rightFin = Path()
      ..moveTo(position.dx + size * 0.8, position.dy)
      ..lineTo(position.dx, position.dy - size * 0.3)
      ..lineTo(position.dx, position.dy + size * 0.3)
      ..close();
    canvas.drawPath(rightFin, flightPaint);
    canvas.drawPath(rightFin, strokePaint);

    // Bottom fin
    final bottomFin = Path()
      ..moveTo(position.dx, position.dy + size * 0.8)
      ..lineTo(position.dx + size * 0.3, position.dy)
      ..lineTo(position.dx - size * 0.3, position.dy)
      ..close();
    canvas.drawPath(bottomFin, flightPaint);
    canvas.drawPath(bottomFin, strokePaint);

    // Left fin
    final leftFin = Path()
      ..moveTo(position.dx - size * 0.8, position.dy)
      ..lineTo(position.dx, position.dy + size * 0.3)
      ..lineTo(position.dx, position.dy - size * 0.3)
      ..close();
    canvas.drawPath(leftFin, flightPaint);
    canvas.drawPath(leftFin, strokePaint);

    // Draw barrel (center circle)
    final barrelPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, size * 0.25, barrelPaint);

    // Barrel outline
    canvas.drawCircle(position, size * 0.25, strokePaint);
  }

  @override
  bool shouldRepaint(DartboardPainter oldDelegate) => true;
}
