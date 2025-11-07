import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    // Initialize with 2 random players (will be replaced if loaded from storage)
    _playerNames = [
      NameGenerator.getRandomName(),
      NameGenerator.getUniqueName([]),
    ];
    _playerPaused = [false, false]; // Both active by default
    _playerPauseReason = ['', '']; // Empty initially

    // Load players from storage
    _loadPlayers();
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
    savePlayers(); // Auto-save
  }

  /// Set countdown out rule
  void setCountdownOutRule(String rule) {
    _countdownOutRule = rule;
    notifyListeners();
    savePlayers(); // Auto-save
  }

  /// Add a new player with a random name
  void addPlayer() {
    final newName = NameGenerator.getUniqueName(_playerNames);
    _playerNames.add(newName);
    _playerPaused.add(false); // New player is active by default
    _playerPauseReason.add(''); // No reason initially
    notifyListeners();
    savePlayers(); // Auto-save
  }

  /// Remove a player at index
  void removePlayer(int index) {
    if (index >= 0 && index < _playerNames.length) {
      _playerNames.removeAt(index);
      _playerPaused.removeAt(index);
      _playerPauseReason.removeAt(index);
      notifyListeners();
      savePlayers(); // Auto-save
    }
  }

  /// Update a player's name
  void updatePlayerName(int index, String newName) {
    if (index >= 0 && index < _playerNames.length && newName.isNotEmpty) {
      _playerNames[index] = newName;
      notifyListeners();
      savePlayers(); // Auto-save
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
    savePlayers(); // Auto-save
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
        savePlayers(); // Auto-save
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

  /// Save players to local storage
  Future<void> savePlayers() async {
    try {
      if (kDebugMode) {
        print('Saving players: $_playerNames');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('player_names', _playerNames);
      await prefs.setStringList(
        'player_paused',
        _playerPaused.map((p) => p.toString()).toList(),
      );
      await prefs.setStringList('player_pause_reason', _playerPauseReason);
      await prefs.setString('countdown_in_rule', _countdownInRule);
      await prefs.setString('countdown_out_rule', _countdownOutRule);
      if (kDebugMode) {
        print('Players saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving players: $e');
      }
    }
  }

  /// Load players from local storage
  Future<void> _loadPlayers() async {
    try {
      if (kDebugMode) {
        print('Loading players from storage...');
      }
      final prefs = await SharedPreferences.getInstance();
      final names = prefs.getStringList('player_names');

      if (kDebugMode) {
        print('Loaded names: $names');
      }

      if (names != null && names.isNotEmpty) {
        _playerNames.clear();
        _playerNames.addAll(names);

        final paused = prefs.getStringList('player_paused');
        if (paused != null && paused.length == names.length) {
          _playerPaused.clear();
          _playerPaused.addAll(paused.map((p) => p == 'true'));
        } else {
          _playerPaused.clear();
          _playerPaused.addAll(List.filled(names.length, false));
        }

        final reasons = prefs.getStringList('player_pause_reason');
        if (reasons != null && reasons.length == names.length) {
          _playerPauseReason.clear();
          _playerPauseReason.addAll(reasons);
        } else {
          _playerPauseReason.clear();
          _playerPauseReason.addAll(List.filled(names.length, ''));
        }

        notifyListeners();
      } else {
        if (kDebugMode) {
          print('No saved players found, using defaults');
        }
      }

      // Load countdown rules
      final inRule = prefs.getString('countdown_in_rule');
      if (inRule != null) {
        _countdownInRule = inRule;
      }

      final outRule = prefs.getString('countdown_out_rule');
      if (outRule != null) {
        _countdownOutRule = outRule;
      }

      if (kDebugMode) {
        print(
          'Loaded countdown rules - In: $_countdownInRule, Out: $_countdownOutRule',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading players: $e');
      }
    }
  }
}
