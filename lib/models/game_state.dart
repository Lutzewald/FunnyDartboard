import 'arrow.dart';
import 'player.dart';

/// Captures a snapshot of the game state for undo functionality
class GameState {
  final int currentPlayerIndex;
  final List<Arrow?> arrows;
  final Map<int, int> playerScores; // playerIndex -> score
  final Map<String, int> fieldHits; // "fieldValue_playerIndex" -> hits
  final bool turnBusted; // Track if turn was busted

  GameState({
    required this.currentPlayerIndex,
    required this.arrows,
    required this.playerScores,
    required this.fieldHits,
    required this.turnBusted,
  });

  /// Create a deep copy of the state
  GameState copyWith({
    int? currentPlayerIndex,
    List<Arrow?>? arrows,
    Map<int, int>? playerScores,
    Map<String, int>? fieldHits,
    bool? turnBusted,
  }) {
    return GameState(
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      arrows: arrows ?? List.from(this.arrows),
      playerScores: playerScores ?? Map.from(this.playerScores),
      fieldHits: fieldHits ?? Map.from(this.fieldHits),
      turnBusted: turnBusted ?? this.turnBusted,
    );
  }

  /// Create a state from current game data
  factory GameState.fromGame({
    required int currentPlayerIndex,
    required List<Arrow?> arrows,
    required List<Player> players,
    required Map<String, int> fieldHits,
    required bool turnBusted,
  }) {
    final playerScores = <int, int>{};
    for (int i = 0; i < players.length; i++) {
      playerScores[i] = players[i].score;
    }

    return GameState(
      currentPlayerIndex: currentPlayerIndex,
      arrows: List.from(arrows),
      playerScores: playerScores,
      fieldHits: Map.from(fieldHits),
      turnBusted: turnBusted,
    );
  }
}
