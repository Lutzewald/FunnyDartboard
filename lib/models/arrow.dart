/// Represents a dart throw on the board
class Arrow {
  final double x;
  final double y;
  final int number; // The field number (1-20, 25 for bullseye)
  final int multiplier; // 0=miss, 1=single, 2=double, 3=triple
  int score; // Points scored by this throw

  Arrow({
    required this.x,
    required this.y,
    required this.number,
    required this.multiplier,
    this.score = 0,
  });

  /// Get the X position on the board
  double getX() => x;

  /// Get the Y position on the board
  double getY() => y;

  /// Get the field number
  int getNumber() => number;

  /// Get the multiplier
  int getMultiplier() => multiplier;

  /// Set the score for this throw
  void setScore(int newScore) {
    score = newScore;
  }

  /// Get the score for this throw
  int getScore() => score;

  @override
  String toString() {
    if (multiplier == 0) return 'Miss';
    return '$multiplier X $number';
  }

  /// Create a copy of the arrow with optional new values
  Arrow copyWith({
    double? x,
    double? y,
    int? number,
    int? multiplier,
    int? score,
  }) {
    return Arrow(
      x: x ?? this.x,
      y: y ?? this.y,
      number: number ?? this.number,
      multiplier: multiplier ?? this.multiplier,
      score: score ?? this.score,
    );
  }
}

