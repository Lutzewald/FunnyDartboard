import '../models/arrow.dart';
import '../models/player.dart';
import 'dart_game.dart';

/// Cricket game mode - open fields 15-20 and bullseye, score points
class Cricket extends DartGame {
  Cricket({required super.numberOfPlayers, super.playerNames}) {
    setPlayerScores(0);

    // Make fields 1-14 not valuable (only 15-20 and bullseye count)
    for (int i = 1; i < 15; i++) {
      getField(i).setValuable(false);
    }
  }

  @override
  void calculateThrow(Arrow arrow) {
    final hitField = getField(arrow.getNumber());
    int points = 0;

    // For each hit (multiplier), check if it scores points
    for (int i = 0; i < arrow.getMultiplier(); i++) {
      // Score points if this player has opened the field and it's not closed
      if (hitField.isOpenByPlayer(currentPlayer) && !hitField.isClosed()) {
        points += hitField.getValue();
      }
      hitField.increasePlayerHits(currentPlayer, 1);
    }

    arrow.setScore(points);
    currentPlayer.raiseScore(points);
    checkGameOver();
  }

  /// Check if the game is over (all fields closed and current player has highest score)
  void checkGameOver() {
    // Check if current player has opened all fields
    int openFieldsCount = 0;
    for (int fieldValue = 15; fieldValue <= 20; fieldValue++) {
      if (getField(fieldValue).isOpenByPlayer(currentPlayer)) {
        openFieldsCount++;
      }
    }
    // Check bullseye
    if (getField(25).isOpenByPlayer(currentPlayer)) {
      openFieldsCount++;
    }

    // If player has opened all 7 fields and has the best score, they win
    if (openFieldsCount == 7 && _getBestPlayer() == currentPlayer) {
      winner = currentPlayer;
      gameOver = true;
    }
  }

  /// Get the player with the highest score
  Player _getBestPlayer() {
    Player best = players[0];
    for (var player in players) {
      if (player.getScore() > best.getScore()) {
        best = player;
      }
    }
    return best;
  }
}
