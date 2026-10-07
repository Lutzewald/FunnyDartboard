import '../game/countdown.dart';
import '../game/cricket.dart';
import '../game/dart_game.dart';
import '../game/shanghai.dart';

/// A scoring bed, using S/D/T notation (S25 and D25 are the two bulls).
class FinishTarget {
  final int number;
  final int multiplier;

  const FinishTarget(this.number, this.multiplier);

  int get points => number * multiplier;
  String get label => '${['', 'S', 'D', 'T'][multiplier]}$number';
}

class FinishingPaths {
  static final _targets = [
    for (final multiplier in [1, 2, 3])
      for (int number = 20; number >= 1; number--)
        FinishTarget(number, multiplier),
    const FinishTarget(25, 1),
    const FinishTarget(25, 2),
  ];

  /// Find a few shortest winning routes without changing the live game.
  static List<List<FinishTarget>> forGame(DartGame? game) {
    if (game == null || game.isGameOver() || !game.canThrow()) return [];
    final darts = game.getArrows().where((arrow) => arrow == null).length;
    if (game is CountDown) return _countdown(game, darts);
    if (game is Cricket) return _cricket(game, darts);
    if (game is Shanghai) return _shanghai(game, darts);
    return [];
  }

  static bool _matchesRule(String rule, int multiplier) => switch (rule) {
    'double' => multiplier == 2,
    'triple' => multiplier == 3,
    'master' => multiplier == 2 || multiplier == 3,
    _ => true,
  };

  static List<List<FinishTarget>> _countdown(CountDown game, int darts) {
    final result = <List<FinishTarget>>[];
    void search(int score, int left, bool opened, List<FinishTarget> path) {
      if (left == 0 || score <= 0 || score > left * 60 || result.length >= 3) {
        return;
      }
      for (final target in _targets) {
        if (!opened && !_matchesRule(game.inRule, target.multiplier)) continue;
        final remaining = score - target.points;
        if (remaining < 0) continue;
        final next = [...path, target];
        if (remaining == 0) {
          if (_matchesRule(game.outRule, target.multiplier)) result.add(next);
        } else {
          search(remaining, left - 1, true, next);
        }
        if (result.length >= 3) return;
      }
    }

    for (int length = 1; length <= darts && result.length < 3; length++) {
      search(
        game.currentPlayer.getScore(),
        length,
        game.currentPlayerOpened,
        [],
      );
      if (result.isNotEmpty) break;
    }
    return result;
  }

  static List<List<FinishTarget>> _cricket(Cricket game, int darts) {
    const numbers = [20, 19, 18, 17, 16, 15, 25];
    final player = game.currentPlayer;
    final hits = [for (final n in numbers) game.getHits(n, player)];
    final opponentsClosed = [
      for (final n in numbers)
        game.players
            .where((p) => p != player)
            .every((p) => game.getHits(n, p) >= 3),
    ];
    bool wins(List<int> marks, int score) =>
        marks.every((hit) => hit >= 3) &&
        game.players.every(
          (p) =>
              p == player ||
              score > p.getScore() ||
              (score == p.getScore() && player.playerNumber < p.playerNumber),
        );
    final result = <List<FinishTarget>>[];
    void search(List<int> marks, int score, int left, List<FinishTarget> path) {
      if (left == 0 || result.length >= 3) return;
      final requiredDarts = [
        for (int i = 0; i < numbers.length; i++)
          marks[i] >= 3
              ? 0
              : ((3 - marks[i]) / (numbers[i] == 25 ? 2 : 3)).ceil(),
      ].fold(0, (a, b) => a + b);
      if (requiredDarts > left) return;
      for (int i = 0; i < numbers.length; i++) {
        if (marks[i] >= 3 && opponentsClosed[i]) continue;
        for (
          int multiplier = numbers[i] == 25 ? 2 : 3;
          multiplier >= 1;
          multiplier--
        ) {
          final nextMarks = List<int>.of(marks);
          var nextScore = score;
          for (int hit = 0; hit < multiplier; hit++) {
            if (nextMarks[i] >= 3 && !opponentsClosed[i]) {
              nextScore += numbers[i];
            }
            nextMarks[i]++;
          }
          final next = [...path, FinishTarget(numbers[i], multiplier)];
          if (wins(nextMarks, nextScore)) {
            result.add(next);
          } else {
            search(nextMarks, nextScore, left - 1, next);
          }
          if (result.length >= 3) return;
        }
      }
    }

    for (int length = 1; length <= darts; length++) {
      search(hits, player.getScore(), length, []);
      if (result.isNotEmpty) break;
    }
    return result;
  }

  static List<List<FinishTarget>> _shanghai(Shanghai game, int darts) {
    final missing = [
      for (final multiplier in [3, 2, 1])
        if (!game.currentPlayerHitMultipliers.contains(multiplier))
          FinishTarget(game.getTargetNumber(), multiplier),
    ];
    if (missing.isEmpty || missing.length > darts) return [];
    final result = <List<FinishTarget>>[];
    void permute(List<FinishTarget> left, List<FinishTarget> path) {
      if (result.length >= 3) return;
      if (left.isEmpty) {
        result.add(path);
        return;
      }
      for (final target in left) {
        permute(left.where((t) => t != target).toList(), [...path, target]);
      }
    }

    permute(missing, []);
    return result;
  }
}
