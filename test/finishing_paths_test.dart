import 'package:dartboard_flutter/game/countdown.dart';
import 'package:dartboard_flutter/game/cricket.dart';
import 'package:dartboard_flutter/game/shanghai.dart';
import 'package:dartboard_flutter/utils/finishing_paths.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    '170 double out uses both triples and bull, bogey scores are hidden',
    () {
      final game = CountDown(numberOfPlayers: 1, startScore: 170);
      final paths = FinishingPaths.forGame(game);
      expect(paths.first.map((t) => t.label), ['T20', 'T20', 'D25']);
      game.currentPlayer.setScore(169);
      expect(FinishingPaths.forGame(game), isEmpty);
      game.currentPlayer.setScore(171);
      expect(FinishingPaths.forGame(game), isEmpty);
    },
  );

  test('countdown entry and exit rules are obeyed by every suggestion', () {
    for (final entry in ['straight', 'double', 'triple', 'master']) {
      for (final exit in ['straight', 'double', 'triple', 'master']) {
        final game = CountDown(
          numberOfPlayers: 1,
          startScore: 60,
          inRule: entry,
          outRule: exit,
        );
        final paths = FinishingPaths.forGame(game);
        expect(paths, isNotEmpty);
        for (final path in paths) {
          final replay = CountDown(
            numberOfPlayers: 1,
            startScore: 60,
            inRule: entry,
            outRule: exit,
          );
          for (final target in path) {
            replay.throwArrow(0.5, 0.5, [target.number, target.multiplier]);
          }
          expect(replay.isGameOver(), isTrue, reason: '$entry/$exit');
        }
      }
    }
  });

  test('remaining darts, busts and game over hide impossible finishes', () {
    final game = CountDown(numberOfPlayers: 1, startScore: 170);
    game.throwArrow(0, 0, [1, 0]);
    expect(FinishingPaths.forGame(game), isEmpty);
    game.reverseArrow();
    expect(FinishingPaths.forGame(game), isNotEmpty);
    game.currentPlayer.setScore(2);
    game.throwArrow(0, 0, [3, 1]);
    expect(FinishingPaths.forGame(game), isEmpty);
    game.reverseArrow();
    game.throwArrow(0, 0, [1, 2]);
    expect(FinishingPaths.forGame(game), isEmpty);
  });

  test('entry state is restored on undo', () {
    final game = CountDown(
      numberOfPlayers: 1,
      startScore: 62,
      inRule: 'double',
    );
    game.throwArrow(0, 0, [1, 2]);
    expect(game.currentPlayerOpened, isTrue);
    game.reverseArrow();
    expect(game.currentPlayerOpened, isFalse);
    for (final path in FinishingPaths.forGame(game)) {
      expect(path.first.multiplier, 2);
    }
  });

  test('Cricket routes close remaining fields and catch up on score', () {
    final game = Cricket(numberOfPlayers: 2);
    for (final n in [15, 16, 17, 18, 19, 20, 25]) {
      game.getField(n).setPlayerHits(game.currentPlayer, 3);
    }
    game.getField(25).setPlayerHits(game.currentPlayer, 1);
    game.players[1].setScore(50);
    final paths = FinishingPaths.forGame(game);
    expect(paths, isNotEmpty);
    for (final target in paths.first) {
      game.throwArrow(0, 0, [target.number, target.multiplier]);
    }
    expect(game.isGameOver(), isTrue);
  });

  test('Cricket hides finishes requiring more remaining darts', () {
    final game = Cricket(numberOfPlayers: 2);
    expect(FinishingPaths.forGame(game), isEmpty);
    for (final n in [15, 16, 17, 18, 19, 20]) {
      game.getField(n).setPlayerHits(game.currentPlayer, 3);
    }
    game.throwArrow(0, 0, [1, 0]);
    game.throwArrow(0, 0, [1, 0]);
    expect(FinishingPaths.forGame(game), isEmpty);
  });

  test('Shanghai adapts to hits, misses, undo and round changes', () {
    final game = Shanghai(numberOfPlayers: 1);
    expect(FinishingPaths.forGame(game).first.map((t) => t.label), [
      'T1',
      'D1',
      'S1',
    ]);
    game.throwArrow(0, 0, [1, 3]);
    expect(FinishingPaths.forGame(game).first.map((t) => t.label), [
      'D1',
      'S1',
    ]);
    game.throwArrow(0, 0, [2, 1]);
    expect(FinishingPaths.forGame(game), isEmpty);
    game.reverseArrow();
    expect(FinishingPaths.forGame(game), isNotEmpty);
    game.nextPlayer();
    expect(game.getTargetNumber(), 2);
    game.reverseArrow();
    expect(game.getTargetNumber(), 1);
    expect(FinishingPaths.forGame(game).first.length, 2);
  });
}
