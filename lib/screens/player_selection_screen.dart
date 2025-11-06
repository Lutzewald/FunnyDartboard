import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/game_provider.dart';
import 'game_screen.dart';
import 'countdown_options_screen.dart';

class PlayerSelectionScreen extends StatelessWidget {
  const PlayerSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown.shade800, Colors.brown.shade600],
          ),
        ),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              return Column(
                children: [
                  const SizedBox(height: 20),

                  // Active players list
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active players section
                          Text(
                            'Aktive Spieler',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade400,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Active players - reorderable
                          Builder(
                            builder: (context) {
                              final activeIndices = <int>[];
                              for (
                                int i = 0;
                                i < gameProvider.numberOfPlayers;
                                i++
                              ) {
                                if (!gameProvider.playerPaused[i]) {
                                  activeIndices.add(i);
                                }
                              }

                              return ReorderableListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                buildDefaultDragHandles: false,
                                itemCount: activeIndices.length,
                                onReorder: (oldIndex, newIndex) {
                                  final realOldIndex = activeIndices[oldIndex];
                                  final realNewIndex = activeIndices[newIndex];
                                  gameProvider.reorderPlayers(
                                    realOldIndex,
                                    realNewIndex,
                                  );
                                },
                                itemBuilder: (context, listIndex) {
                                  final index = activeIndices[listIndex];
                                  return ReorderableDragStartListener(
                                    key: ValueKey('player_$index'),
                                    index: listIndex,
                                    child: _PlayerListItem(
                                      playerName:
                                          gameProvider.playerNames[index],
                                      displayNumber: listIndex + 1,
                                      isPaused: false,
                                      onEdit: () => _showEditDialog(
                                        context,
                                        gameProvider,
                                        index,
                                      ),
                                      onRemove: gameProvider.numberOfPlayers > 1
                                          ? () => _showRemoveDialog(
                                              context,
                                              gameProvider,
                                              index,
                                            )
                                          : null,
                                      onTogglePause: (reason) => gameProvider
                                          .togglePlayerPause(index, reason),
                                    ),
                                  );
                                },
                              );
                            },
                          ),

                          // Paused players section
                          if (gameProvider.numberOfPlayers >
                              gameProvider.numberOfActivePlayers) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Pause',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade400,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Paused players - reorderable
                            Builder(
                              builder: (context) {
                                final pausedIndices = <int>[];
                                for (
                                  int i = 0;
                                  i < gameProvider.numberOfPlayers;
                                  i++
                                ) {
                                  if (gameProvider.playerPaused[i]) {
                                    pausedIndices.add(i);
                                  }
                                }

                                return ReorderableListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  buildDefaultDragHandles: false,
                                  itemCount: pausedIndices.length,
                                  onReorder: (oldIndex, newIndex) {
                                    final realOldIndex =
                                        pausedIndices[oldIndex];
                                    final realNewIndex =
                                        pausedIndices[newIndex];
                                    gameProvider.reorderPlayers(
                                      realOldIndex,
                                      realNewIndex,
                                    );
                                  },
                                  itemBuilder: (context, listIndex) {
                                    final index = pausedIndices[listIndex];
                                    return ReorderableDragStartListener(
                                      key: ValueKey('player_$index'),
                                      index: listIndex,
                                      child: _PlayerListItem(
                                        playerName:
                                            gameProvider.playerNames[index],
                                        displayNumber:
                                            null, // No number for paused players
                                        isPaused: true,
                                        pauseReason: gameProvider
                                            .playerPauseReason[index],
                                        onEdit: () => _showEditDialog(
                                          context,
                                          gameProvider,
                                          index,
                                        ),
                                        onRemove:
                                            gameProvider.numberOfPlayers > 1
                                            ? () => _showRemoveDialog(
                                                context,
                                                gameProvider,
                                                index,
                                              )
                                            : null,
                                        onTogglePause: (reason) => gameProvider
                                            .togglePlayerPause(index, reason),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Add player button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => gameProvider.addPlayer(),
                        icon: const Icon(Icons.person_add, size: 28),
                        label: const Text(
                          'Spieler hinzufügen',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade300,
                          foregroundColor: Colors.brown.shade900,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Start button
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // For 301/501 modes, show options screen first
                          if (gameProvider.selectedGameMode == 0 ||
                              gameProvider.selectedGameMode == 1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CountdownOptionsScreen(),
                              ),
                            );
                          } else {
                            // For Cricket and Shanghai, start game directly
                            gameProvider.startGame();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameScreen(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Start',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    GameProvider gameProvider,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Spieler entfernen',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Möchten Sie ${gameProvider.playerNames[index]} wirklich entfernen?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Abbrechen',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          TextButton(
            onPressed: () {
              gameProvider.removePlayer(index);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: const Text('Entfernen'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    GameProvider gameProvider,
    int index,
  ) {
    final controller = TextEditingController(
      text: gameProvider.playerNames[index],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Namen bearbeiten',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Name eingeben',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.brown.shade400),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.brown.shade300),
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              gameProvider.updatePlayerName(index, value);
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Abbrechen',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                gameProvider.updatePlayerName(index, controller.text);
              }
              Navigator.pop(context);
            },
            child: Text(
              'Speichern',
              style: TextStyle(color: Colors.brown.shade300),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerListItem extends StatelessWidget {
  final String playerName;
  final int? displayNumber; // Null for paused players
  final bool isPaused;
  final String pauseReason;
  final VoidCallback onEdit;
  final VoidCallback? onRemove;
  final Function(String) onTogglePause;

  const _PlayerListItem({
    required this.playerName,
    required this.displayNumber,
    required this.isPaused,
    this.pauseReason = '',
    required this.onEdit,
    this.onRemove,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPaused
            ? Colors.grey.shade900.withValues(alpha: 0.5)
            : Colors.brown.shade800.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaused ? Colors.grey.shade700 : Colors.brown.shade600,
          width: 2,
        ),
      ),
      child: Opacity(
        opacity: isPaused ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First row: drag handle, name, edit button, delete button
            Row(
              children: [
                Icon(Icons.drag_handle, color: Colors.grey.shade600, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        playerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPaused && pauseReason.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _getPauseReasonIcon(pauseReason),
                      ],
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 20),
                        color: Colors.brown.shade300,
                        tooltip: 'Bearbeiten',
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete),
                  color: onRemove != null ? Colors.red.shade400 : Colors.grey,
                  tooltip: 'Entfernen',
                ),
              ],
            ),

            // Second row: pause buttons (centered)
            if (!isPaused) ...[
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    // Beer
                    IconButton(
                      onPressed: () => onTogglePause('beer'),
                      icon: Icon(
                        Icons.sports_bar,
                        color: Colors.orange.shade600,
                        size: 24,
                      ),
                      tooltip: '🍺 Bier',
                      padding: const EdgeInsets.all(8),
                    ),
                    // Toilet
                    IconButton(
                      onPressed: () => onTogglePause('toilet'),
                      icon: Icon(
                        Icons.wc,
                        color: Colors.blue.shade400,
                        size: 24,
                      ),
                      tooltip: '🚽 WC',
                      padding: const EdgeInsets.all(8),
                    ),
                    // Cigarette
                    IconButton(
                      onPressed: () => onTogglePause('smoke'),
                      icon: Icon(
                        Icons.smoking_rooms,
                        color: Colors.grey.shade500,
                        size: 24,
                      ),
                      tooltip: '🚬 Rauchen',
                      padding: const EdgeInsets.all(8),
                    ),
                    // Puking/sick
                    IconButton(
                      onPressed: () => onTogglePause('sick'),
                      icon: Icon(
                        Icons.sick,
                        color: Colors.green.shade300,
                        size: 24,
                      ),
                      tooltip: '🤮 Kotzen',
                      padding: const EdgeInsets.all(8),
                    ),
                    // Love/sex
                    IconButton(
                      onPressed: () => onTogglePause('love'),
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.pink.shade300,
                        size: 24,
                      ),
                      tooltip: '❤️ Liebe',
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Paused player: show return button centered
              const SizedBox(height: 8),
              Center(
                child: IconButton(
                  onPressed: () => onTogglePause(''),
                  icon: Icon(
                    Icons.near_me,
                    color: Colors.green.shade400,
                    size: 32,
                  ),
                  tooltip: 'Zurück zum Spiel',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Helper function to get pause reason icon
Widget _getPauseReasonIcon(String reason) {
  switch (reason) {
    case 'beer':
      return Icon(Icons.sports_bar, color: Colors.orange.shade600, size: 20);
    case 'toilet':
      return Icon(Icons.wc, color: Colors.blue.shade400, size: 20);
    case 'smoke':
      return Icon(Icons.smoking_rooms, color: Colors.grey.shade500, size: 20);
    case 'sick':
      return Icon(Icons.sick, color: Colors.green.shade300, size: 20);
    case 'love':
      return Icon(Icons.favorite, color: Colors.pink.shade300, size: 20);
    default:
      return const SizedBox.shrink();
  }
}
