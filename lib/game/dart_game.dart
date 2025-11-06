import '../models/arrow.dart';
import '../models/dart_field.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'score_based_game.dart';

/// Base class for dart games with dartboard fields
abstract class DartGame extends ScoreBasedGame {
  late List<DartField> fields;
  late List<Arrow?> arrows;
  Player? winner;
  final List<GameState> _history = [];
  bool turnBusted = false; // Track if current turn is busted

  DartGame({required super.numberOfPlayers, super.playerNames}) {
    // Initialize fields 1-20 and bullseye (25)
    fields = List.generate(21, (index) {
      if (index < 20) {
        return DartField(
          value: index + 1,
          numberOfPlayers: getNumberOfPlayers(),
        );
      } else {
        return DartField(value: 25, numberOfPlayers: getNumberOfPlayers());
      }
    });

    // Initialize arrow slots (3 arrows per turn)
    arrows = List.filled(3, null);
  }

  /// Get all arrows for the current turn
  List<Arrow?> getArrows() => arrows;

  /// Throw a dart at the specified position
  void throwArrow(double x, double y, List<int> hit) {
    // Don't allow throws if turn is busted
    if (turnBusted) return;

    // Save state before the throw
    _saveState();

    // Find the first empty arrow slot
    for (int i = 0; i < arrows.length; i++) {
      if (arrows[i] == null) {
        final arrow = Arrow(x: x, y: y, number: hit[0], multiplier: hit[1]);
        arrows[i] = arrow;
        calculateThrow(arrow);
        break;
      }
    }
  }

  /// Check if player can throw (not busted and has empty arrow slots)
  bool canThrow() {
    if (turnBusted) return false;
    return arrows.any((arrow) => arrow == null);
  }

  /// Undo the last action (arrow throw or player change)
  void reverseArrow() {
    if (_history.isEmpty) return;

    // Restore the last saved state
    final previousState = _history.removeLast();
    _restoreState(previousState);
  }

  /// Check if undo is available
  bool canUndo() => _history.isNotEmpty;

  /// Save current game state to history
  void _saveState() {
    final fieldHits = <String, int>{};
    for (final field in fields) {
      for (int i = 0; i < players.length; i++) {
        final key = '${field.getValue()}_$i';
        fieldHits[key] = field.getHits(players[i]);
      }
    }

    final state = GameState.fromGame(
      currentPlayerIndex: currentPlayer.playerNumber,
      arrows: arrows,
      players: players,
      fieldHits: fieldHits,
      turnBusted: turnBusted,
    );
    _history.add(state);
  }

  /// Restore game state from a snapshot
  void _restoreState(GameState state) {
    // Restore current player
    currentPlayer = players[state.currentPlayerIndex];

    // Restore arrows
    arrows = List.from(state.arrows);

    // Restore bust flag
    turnBusted = state.turnBusted;

    // Restore player scores
    for (int i = 0; i < players.length; i++) {
      players[i].setScore(state.playerScores[i] ?? 0);
    }

    // Restore field hits
    for (final field in fields) {
      for (int i = 0; i < players.length; i++) {
        final key = '${field.getValue()}_$i';
        final hits = state.fieldHits[key] ?? 0;
        field.setPlayerHits(players[i], hits);
      }
    }
  }

  /// Get a specific field by its value
  DartField getField(int value) {
    if (value == 25) {
      return fields[20];
    }
    return fields[value - 1];
  }

  /// Calculate the score and effects of a throw (implemented by subclasses)
  void calculateThrow(Arrow arrow);

  @override
  void nextPlayer() {
    // Save current state before switching players
    _saveState();

    // Clear arrows for the next player
    arrows = List.filled(3, null);
    turnBusted = false; // Reset bust flag
    // Move to the next player (playerNumber is 0-indexed internally)
    final nextIndex = (currentPlayer.playerNumber + 1) % getNumberOfPlayers();
    currentPlayer = players[nextIndex];
  }

  /// Get a specific player by index
  Player getPlayer(int index) => players[index];

  /// Get the winner of the game
  Player? getWinner() => winner;

  /// Get the number of hits on a field by a specific player
  int getHits(int fieldValue, Player player) {
    return getField(fieldValue).getHits(player);
  }
}
