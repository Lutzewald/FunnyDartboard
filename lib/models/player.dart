/// Represents a player in the dart game
class Player {
  final int playerNumber;
  String name;
  int score;

  Player({required this.playerNumber, required this.name, this.score = 0});

  /// Get the player number (1-indexed for display)
  int getPlayerNumber() => playerNumber + 1;

  /// Set the player's score
  void setScore(int newScore) {
    score = newScore;
  }

  /// Get the player's current score
  int getScore() => score;

  /// Add points to the player's score (can be negative)
  void raiseScore(int points) {
    score += points;
  }

  /// Create a copy of the player with optional new values
  Player copyWith({int? playerNumber, String? name, int? score}) {
    return Player(
      playerNumber: playerNumber ?? this.playerNumber,
      name: name ?? this.name,
      score: score ?? this.score,
    );
  }
}
