import 'player.dart';

/// Represents a numbered field on the dartboard
class DartField {
  final int value; // The number on the field (1-20, 25 for bullseye)
  final List<int> playersHits; // Hits per player
  bool valuable; // Whether this field scores points (used in Cricket)
  Player? owner; // The player who owns this field (if any)

  DartField({
    required this.value,
    required int numberOfPlayers,
    this.valuable = true,
  }) : playersHits = List<int>.filled(numberOfPlayers, 0),
       owner = null;

  /// Get the owner of this field
  Player? getOwner() => owner;

  /// Check if this field is valuable (scores points)
  bool isValuable() => valuable;

  /// Set whether this field is valuable
  void setValuable(bool isValuable) {
    valuable = isValuable;
  }

  /// Get the value of this field
  int getValue() => valuable ? value : 0;

  /// Increase a player's hit count on this field
  void increasePlayerHits(Player player, int multiplier) {
    playersHits[player.playerNumber] += multiplier;
  }

  /// Check if any player has opened this field (3+ hits in Cricket)
  bool isOpen() {
    return playersHits.any((hits) => hits >= 3);
  }

  /// Check if a specific player has opened this field
  bool isOpenByPlayer(Player player) {
    return playersHits[player.playerNumber] >= 3;
  }

  /// Check if all players have closed this field
  bool isClosed() {
    return playersHits.every((hits) => hits >= 3);
  }

  /// Get the number of hits a player has on this field
  int getHits(Player player) {
    return playersHits[player.playerNumber];
  }

  /// Set the number of hits for a player (used for state restoration)
  void setPlayerHits(Player player, int hits) {
    playersHits[player.playerNumber] = hits;
  }
}
