import '../models/arrow.dart';
import 'dart_game.dart';

/// Shanghai game mode - hit target numbers 1-7 in sequence
class Shanghai extends DartGame {
  int currentTargetNumber = 1; // Start with 1
  final int maxRounds = 7; // Play rounds 1-7
  final Map<int, List<int>> _playerHitMultipliers =
      {}; // Track multipliers hit per player per round

  Shanghai({required super.numberOfPlayers, super.playerNames}) {
    setPlayerScores(0);
    // Initialize multiplier tracking
    for (int i = 0; i < getNumberOfPlayers(); i++) {
      _playerHitMultipliers[i] = [];
    }
  }

  @override
  void calculateThrow(Arrow arrow) {
    final hitField = getField(arrow.getNumber());
    final multiplier = arrow.getMultiplier();
    final number = arrow.getNumber();

    hitField.increasePlayerHits(currentPlayer, multiplier);

    // Only score if hitting the target number
    if (number == currentTargetNumber) {
      final points = currentTargetNumber * multiplier;
      arrow.setScore(points);
      currentPlayer.raiseScore(points);

      // Track multipliers hit this round
      if (!_playerHitMultipliers[currentPlayer.playerNumber]!.contains(
        multiplier,
      )) {
        _playerHitMultipliers[currentPlayer.playerNumber]!.add(multiplier);
      }

      // Check for Shanghai (hit single, double, and triple of target number)
      if (_playerHitMultipliers[currentPlayer.playerNumber]!.contains(1) &&
          _playerHitMultipliers[currentPlayer.playerNumber]!.contains(2) &&
          _playerHitMultipliers[currentPlayer.playerNumber]!.contains(3)) {
        // Shanghai! Instant win
        winner = currentPlayer;
        gameOver = true;
      }
    } else {
      // Didn't hit target number - no points
      arrow.setScore(0);
    }
  }

  @override
  void nextPlayer() {
    // Clear multiplier tracking for this player's round
    _playerHitMultipliers[currentPlayer.playerNumber] = [];

    // Check if we need to advance to next round
    final nextIndex = (currentPlayer.playerNumber + 1) % getNumberOfPlayers();

    // If we're back to player 0, advance to next target number
    if (nextIndex == 0) {
      currentTargetNumber++;

      // Check if game is over (completed all rounds)
      if (currentTargetNumber > maxRounds) {
        gameOver = true;
        // Find winner (highest score)
        winner = players.reduce((a, b) => a.getScore() > b.getScore() ? a : b);
      }
    }

    // Call parent to handle arrows reset and player switching
    super.nextPlayer();
  }

  /// Get the current target number
  int getTargetNumber() => currentTargetNumber;

  /// Get the current round (1-7)
  int getCurrentRound() => currentTargetNumber;

  /// Get total rounds
  int getTotalRounds() => maxRounds;
}

