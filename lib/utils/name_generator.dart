import 'dart:math';

/// Generates random German names for players
class NameGenerator {
  static final Random _random = Random();

  static const List<String> _germanNames = [
    'Max',
    'Anna',
    'Leon',
    'Marie',
    'Paul',
    'Sophie',
    'Felix',
    'Emma',
    'Lukas',
    'Mia',
    'Jonas',
    'Hannah',
    'Tim',
    'Laura',
    'Finn',
    'Lena',
    'Noah',
    'Lea',
    'Ben',
    'Sarah',
    'Tom',
    'Julia',
    'Jan',
    'Lisa',
    'Nico',
    'Nina',
    'Daniel',
    'Clara',
    'Simon',
    'Lara',
    'David',
    'Emily',
    'Marco',
    'Maja',
    'Stefan',
    'Sophia',
    'Tobias',
    'Elena',
    'Michael',
    'Amelie',
  ];

  /// Get a random German name
  static String getRandomName() {
    return _germanNames[_random.nextInt(_germanNames.length)];
  }

  /// Get a unique random name that's not in the used names list
  static String getUniqueName(List<String> usedNames) {
    final availableNames = _germanNames
        .where((name) => !usedNames.contains(name))
        .toList();

    if (availableNames.isEmpty) {
      // If all names are used, add a number suffix
      final baseName = _germanNames[_random.nextInt(_germanNames.length)];
      int suffix = 2;
      String newName = '$baseName $suffix';
      while (usedNames.contains(newName)) {
        suffix++;
        newName = '$baseName $suffix';
      }
      return newName;
    }

    return availableNames[_random.nextInt(availableNames.length)];
  }
}

