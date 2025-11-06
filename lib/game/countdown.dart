import '../models/arrow.dart';
import 'dart_game.dart';

/// 301/501 game mode - count down from starting score to exactly 0
class CountDown extends DartGame {
  final int startScore;
  final String inRule; // straight, double, triple, master
  final String outRule; // straight, double, triple, master
  final Map<int, bool> _playerOpened = {}; // Track which players have "opened"

  CountDown({
    required super.numberOfPlayers,
    required this.startScore,
    super.playerNames,
    this.inRule = 'straight',
    this.outRule = 'double',
  }) {
    setPlayerScores(startScore);
    // Initialize all players as not opened (except for straight in)
    for (int i = 0; i < getNumberOfPlayers(); i++) {
      _playerOpened[i] = inRule == 'straight';
    }
  }

  @override
  void calculateThrow(Arrow arrow) {
    final hitField = getField(arrow.getNumber());
    final multiplier = arrow.getMultiplier();

    // Check if player has opened
    final isOpened = _playerOpened[currentPlayer.playerNumber] ?? false;

    // Check if this throw opens the game for the player
    if (!isOpened) {
      final opensGame = _checkOpensGame(multiplier);
      if (opensGame) {
        _playerOpened[currentPlayer.playerNumber] = true;
      } else {
        // Throw doesn't count, just mark it
        hitField.increasePlayerHits(currentPlayer, multiplier);
        arrow.setScore(0);
        return;
      }
    }

    hitField.increasePlayerHits(currentPlayer, multiplier);

    final pointsThrown = hitField.getValue() * multiplier;
    final newScore = currentPlayer.getScore() - pointsThrown;

    // Check for win (exactly 0)
    if (newScore == 0) {
      // Check out rule
      if (_checkFinishesGame(multiplier)) {
        arrow.setScore(-pointsThrown);
        currentPlayer.raiseScore(-pointsThrown);
        winner = currentPlayer;
        gameOver = true;
      } else {
        // Invalid finish, bust - revert score but keep arrows visible
        arrow.setScore(0);
        _bustTurn();
      }
      return;
    }

    // If score goes below 0, bust - revert score but keep arrows visible
    if (newScore < 0) {
      arrow.setScore(0);
      _bustTurn();
      return;
    }

    // Valid throw
    if (newScore >= 0) {
      arrow.setScore(-pointsThrown);
      currentPlayer.raiseScore(-pointsThrown);
    }
  }

  /// Handle a busted turn - revert score changes but keep arrows visible
  void _bustTurn() {
    // Mark turn as busted to prevent further throws
    turnBusted = true;

    // Revert all score changes from this turn
    for (final arrow in arrows) {
      if (arrow != null && arrow.getScore() != 0) {
        currentPlayer.raiseScore(-arrow.getScore());
        arrow.setScore(0);
      }
    }
  }

  /// Check if a multiplier opens the game based on in rule
  bool _checkOpensGame(int multiplier) {
    switch (inRule) {
      case 'straight':
        return true;
      case 'double':
        return multiplier == 2;
      case 'triple':
        return multiplier == 3;
      case 'master':
        return multiplier == 2 || multiplier == 3;
      default:
        return true;
    }
  }

  /// Check if a multiplier finishes the game based on out rule
  bool _checkFinishesGame(int multiplier) {
    switch (outRule) {
      case 'straight':
        return true;
      case 'double':
        return multiplier == 2;
      case 'triple':
        return multiplier == 3;
      case 'master':
        return multiplier == 2 || multiplier == 3;
      default:
        return true;
    }
  }
}
