import 'dart:math';

/// Utility class for calculating dartboard hit detection
class DartboardCalculator {
  /// Calculate which field and multiplier was hit based on tap position
  /// Returns [fieldNumber, multiplier] where multiplier: 0=miss, 1=single, 2=double, 3=triple
  static List<int> calculateHit(
    double x,
    double y,
    double centerX,
    double centerY,
    double boardRadius,
  ) {
    // Calculate offset from center
    final dx = x - centerX;
    final dy = y - centerY;

    // Calculate angle (0-360 degrees)
    final angle = _calculateAngle(dx, dy);

    // Calculate distance from center (normalized to 0-1000)
    final distance = _calculateDistance(dx, dy, boardRadius);

    // Determine field number based on angle
    int field = _getFieldFromAngle(angle);

    // Determine multiplier based on distance
    int multiplier = _getMultiplierFromDistance(distance);

    // Bullseye override
    if (distance <= 100) {
      field = 25;
    }

    return [field, multiplier];
  }

  /// Calculate angle in degrees (0-360)
  /// Dartboard has 0 degrees at top, increasing clockwise
  static double _calculateAngle(double dx, double dy) {
    // atan2 gives angle from positive x-axis (right), counterclockwise
    // We need angle from positive y-axis (top), clockwise
    // So we convert: top=0°, right=90°, bottom=180°, left=270°
    double angle = atan2(dx, -dy) * 180 / pi;

    // Ensure 0-360 range
    if (angle < 0) angle += 360;

    return angle;
  }

  /// Calculate normalized distance (0-1000 scale)
  static double _calculateDistance(double dx, double dy, double boardRadius) {
    final actualDistance = sqrt(dx * dx + dy * dy);
    return (actualDistance / boardRadius) * 1000;
  }

  /// Get field number from angle
  static int _getFieldFromAngle(double angle) {
    // Correct dartboard layout (clockwise from top)
    // 20 1 18 4 13 6 10 15 2 17 3 19 7 16 8 11 14 9 12 5
    const fields = [
      20, // 0: Top center
      1, // 1
      18, // 2
      4, // 3
      13, // 4
      6, // 5
      10, // 6
      15, // 7
      2, // 8
      17, // 9
      3, // 10
      19, // 11
      7, // 12
      16, // 13
      8, // 14
      11, // 15
      14, // 16
      9, // 17
      12, // 18
      5, // 19
    ];

    // Each field occupies 18 degrees
    // Field 20 is centered at top (0°) so it spans from 351° to 9°
    const sectorSize = 18.0;

    // Add 9 degrees offset so field 20 is centered at 0°
    final adjustedAngle = (angle + 9) % 360;

    // Calculate which sector (0-19)
    final sector = (adjustedAngle ~/ sectorSize) % 20;

    return fields[sector];
  }

  /// Get multiplier from distance
  static int _getMultiplierFromDistance(double distance) {
    if (distance <= 38 || (distance >= 932 && distance <= 1000)) {
      return 2; // Double
    } else if (distance >= 565 && distance <= 635) {
      return 3; // Triple
    } else if (distance > 1000) {
      return 0; // Miss
    }
    return 1; // Single
  }
}
