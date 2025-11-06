import '../models/player.dart';

/// Base class for score-based dart games
abstract class ScoreBasedGame {
  late List<Player> players;
  late Player currentPlayer;
  bool gameOver = false;

  ScoreBasedGame({int numberOfPlayers = 1, List<String>? playerNames}) {
    players = List.generate(
      numberOfPlayers,
      (index) => Player(
        playerNumber: index,
        name: playerNames != null && index < playerNames.length
            ? playerNames[index]
            : 'Spieler ${index + 1}',
      ),
    );
    currentPlayer = players[0];
  }

  /// Get the number of players
  int getNumberOfPlayers() => players.length;

  /// Get the current player
  Player getCurrentPlayer() => currentPlayer;

  /// Check if the game is over
  bool isGameOver() => gameOver;

  /// Set all players' scores to a specific value
  void setPlayerScores(int score) {
    for (var player in players) {
      player.setScore(score);
    }
  }

  /// Move to the next player
  void nextPlayer();
}
