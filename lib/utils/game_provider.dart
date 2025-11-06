import 'package:flutter/foundation.dart';
import '../game/dart_game.dart';
import '../game/countdown.dart';
import '../game/cricket.dart';
import '../game/shanghai.dart';
import '../models/player.dart';
import 'name_generator.dart';

/// Manages the game state for the entire app
class GameProvider extends ChangeNotifier {
  DartGame? _currentGame;
  int _selectedGameMode = 0; // 0 = 301, 1 = 501, 2 = Cricket, 3 = Shanghai
  late final List<String> _playerNames;
  late final List<bool> _playerPaused; // Track which players are paused
  late final List<String>
  _playerPauseReason; // Track pause reason: 'beer', 'toilet', 'smoke', 'sick', 'love'
  String _countdownInRule = 'straight'; // straight, double, triple, master
  String _countdownOutRule = 'double'; // straight, double, triple, master

  GameProvider() {
    // Initialize with 2 random players
    _playerNames = [
      NameGenerator.getRandomName(),
      NameGenerator.getUniqueName([]),
    ];
    _playerPaused = [false, false]; // Both active by default
    _playerPauseReason = ['', '']; // Empty initially
  }

  DartGame? get currentGame => _currentGame;
  int get selectedGameMode => _selectedGameMode;
  int get numberOfPlayers => _playerNames.length;
  int get numberOfActivePlayers => _playerPaused.where((p) => !p).length;
  List<String> get playerNames => List.unmodifiable(_playerNames);
  List<bool> get playerPaused => List.unmodifiable(_playerPaused);
  List<String> get playerPauseReason => List.unmodifiable(_playerPauseReason);
  String get countdownInRule => _countdownInRule;
  String get countdownOutRule => _countdownOutRule;

  bool get isGameActive => _currentGame != null;
  bool get isGameOver => _currentGame?.isGameOver() ?? false;
  bool get canUndo => _currentGame?.canUndo() ?? false;
  bool get canThrow => _currentGame?.canThrow() ?? false;
  Player? get currentPlayer => _currentGame?.getCurrentPlayer();
  Player? get winner => _currentGame?.getWinner();

  /// Set the selected game mode
  void setGameMode(int mode) {
    _selectedGameMode = mode;
    notifyListeners();
  }

  /// Set countdown in rule
  void setCountdownInRule(String rule) {
    _countdownInRule = rule;
    notifyListeners();
  }

  /// Set countdown out rule
  void setCountdownOutRule(String rule) {
    _countdownOutRule = rule;
    notifyListeners();
  }

  /// Add a new player with a random name
  void addPlayer() {
    final newName = NameGenerator.getUniqueName(_playerNames);
    _playerNames.add(newName);
    _playerPaused.add(false); // New player is active by default
    _playerPauseReason.add(''); // No reason initially
    notifyListeners();
  }

  /// Remove a player at index
  void removePlayer(int index) {
    if (_playerNames.length > 1 && index >= 0 && index < _playerNames.length) {
      _playerNames.removeAt(index);
      _playerPaused.removeAt(index);
      _playerPauseReason.removeAt(index);
      notifyListeners();
    }
  }

  /// Update a player's name
  void updatePlayerName(int index, String newName) {
    if (index >= 0 && index < _playerNames.length && newName.isNotEmpty) {
      _playerNames[index] = newName;
      notifyListeners();
    }
  }

  /// Reorder players
  void reorderPlayers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final name = _playerNames.removeAt(oldIndex);
    final paused = _playerPaused.removeAt(oldIndex);
    final reason = _playerPauseReason.removeAt(oldIndex);

    _playerNames.insert(newIndex, name);
    _playerPaused.insert(newIndex, paused);
    _playerPauseReason.insert(newIndex, reason);

    notifyListeners();
  }

  /// Toggle player pause status with reason
  void togglePlayerPause(int index, [String reason = '']) {
    if (index >= 0 && index < _playerPaused.length) {
      // Don't allow pausing if it would leave no active players
      final activeCount = _playerPaused.where((p) => !p).length;
      if (_playerPaused[index] || activeCount > 1) {
        _playerPaused[index] = !_playerPaused[index];
        _playerPauseReason[index] = _playerPaused[index] ? reason : '';
        notifyListeners();
      }
    }
  }

  /// Start a new game with current players (only active ones)
  void startGame() {
    // Get only active (non-paused) players
    final activePlayerNames = <String>[];
    for (int i = 0; i < _playerNames.length; i++) {
      if (!_playerPaused[i]) {
        activePlayerNames.add(_playerNames[i]);
      }
    }

    if (activePlayerNames.isEmpty) return; // Safety check

    if (_selectedGameMode == 0 || _selectedGameMode == 1) {
      // 301 or 501
      final startScore = _selectedGameMode == 0 ? 301 : 501;
      _currentGame = CountDown(
        numberOfPlayers: activePlayerNames.length,
        startScore: startScore,
        playerNames: activePlayerNames,
        inRule: _countdownInRule,
        outRule: _countdownOutRule,
      );
    } else if (_selectedGameMode == 2) {
      // Cricket
      _currentGame = Cricket(
        numberOfPlayers: activePlayerNames.length,
        playerNames: activePlayerNames,
      );
    } else if (_selectedGameMode == 3) {
      // Shanghai
      _currentGame = Shanghai(
        numberOfPlayers: activePlayerNames.length,
        playerNames: activePlayerNames,
      );
    }
    notifyListeners();
  }

  /// Throw a dart at the specified position
  void throwDart(double x, double y, List<int> hit) {
    _currentGame?.throwArrow(x, y, hit);
    notifyListeners();
  }

  /// Undo the last throw
  void undoLastThrow() {
    _currentGame?.reverseArrow();
    notifyListeners();
  }

  /// Move to the next player
  void nextPlayer() {
    _currentGame?.nextPlayer();
    notifyListeners();
  }

  /// Reset the game and return to main menu
  void resetGame() {
    _currentGame = null;
    notifyListeners();
  }

  /// Get a specific player by index
  Player? getPlayer(int index) {
    return _currentGame?.getPlayer(index);
  }

  /// Get hits on a field for a player
  int getHits(int fieldValue, Player player) {
    return _currentGame?.getHits(fieldValue, player) ?? 0;
  }
}
