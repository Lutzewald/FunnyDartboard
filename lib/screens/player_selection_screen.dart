import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/game_provider.dart';
import '../l10n/app_localizations.dart';
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
                            AppLocalizations.of(context)!.activePlayers,
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
                                proxyDecorator: (child, index, animation) {
                                  return AnimatedBuilder(
                                    animation: animation,
                                    builder: (context, child) {
                                      return Material(
                                        elevation: 8,
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        child: child,
                                      );
                                    },
                                    child: child,
                                  );
                                },
                                onReorder: (oldIndex, newIndex) {
                                  // Adjust newIndex when dragging down
                                  if (newIndex > oldIndex) {
                                    newIndex -= 1;
                                  }
                                  final realOldIndex = activeIndices[oldIndex];
                                  final realNewIndex = activeIndices[newIndex];
                                  gameProvider.reorderPlayers(
                                    realOldIndex,
                                    realNewIndex,
                                  );
                                },
                                itemBuilder: (context, listIndex) {
                                  final index = activeIndices[listIndex];
                                  return _PlayerListItem(
                                    key: ValueKey('player_$index'),
                                    playerName: gameProvider.playerNames[index],
                                    displayNumber: listIndex + 1,
                                    isPaused: false,
                                    dragIndex: listIndex,
                                    onEdit: () => _showEditDialog(
                                      context,
                                      gameProvider,
                                      index,
                                    ),
                                    onRemove: () =>
                                        gameProvider.removePlayer(index),
                                    onTogglePause: (reason) => gameProvider
                                        .togglePlayerPause(index, reason),
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
                              AppLocalizations.of(context)!.pause,
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
                                  proxyDecorator: (child, index, animation) {
                                    return AnimatedBuilder(
                                      animation: animation,
                                      builder: (context, child) {
                                        return Material(
                                          elevation: 8,
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: child,
                                        );
                                      },
                                      child: child,
                                    );
                                  },
                                  onReorder: (oldIndex, newIndex) {
                                    // Adjust newIndex when dragging down
                                    if (newIndex > oldIndex) {
                                      newIndex -= 1;
                                    }
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
                                    return _PlayerListItem(
                                      key: ValueKey('player_$index'),
                                      playerName:
                                          gameProvider.playerNames[index],
                                      displayNumber:
                                          null, // No number for paused players
                                      isPaused: true,
                                      dragIndex: listIndex,
                                      pauseReason:
                                          gameProvider.playerPauseReason[index],
                                      onEdit: () => _showEditDialog(
                                        context,
                                        gameProvider,
                                        index,
                                      ),
                                      onRemove: () =>
                                          gameProvider.removePlayer(index),
                                      onTogglePause: (reason) => gameProvider
                                          .togglePlayerPause(index, reason),
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
                        label: Text(
                          AppLocalizations.of(context)!.addPlayer,
                          style: const TextStyle(
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
                        onPressed: gameProvider.numberOfActivePlayers > 0
                            ? () {
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
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.start,
                          style: const TextStyle(
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

  void _showEditDialog(
    BuildContext context,
    GameProvider gameProvider,
    int index,
  ) {
    final controller = TextEditingController(
      text: gameProvider.playerNames[index],
    );

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(l10n.editName, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.enterName,
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
              l10n.cancel,
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
              l10n.save,
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
  final int dragIndex;
  final String pauseReason;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final Function(String) onTogglePause;

  const _PlayerListItem({
    super.key,
    required this.playerName,
    required this.displayNumber,
    required this.isPaused,
    required this.dragIndex,
    this.pauseReason = '',
    required this.onEdit,
    required this.onRemove,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag handle - centered vertically (only for active players)
            if (!isPaused) ...[
              ReorderableDragStartListener(
                index: dragIndex,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.drag_handle,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Main content - name, edit button, and pause buttons below
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First row: name and edit button
                  Row(
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
                      if (!isPaused) ...[
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 20),
                            color: Colors.brown.shade300,
                            tooltip: AppLocalizations.of(context)!.edit,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Second row: pause buttons (only for active players)
                  if (!isPaused) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 0,
                      runSpacing: 0,
                      children: [
                        // Beer
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () => onTogglePause('beer'),
                            icon: Icon(
                              Icons.sports_bar,
                              color: Colors.orange.shade600,
                              size: 18,
                            ),
                            tooltip: AppLocalizations.of(context)!.pauseBeer,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        // Toilet
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () => onTogglePause('toilet'),
                            icon: Icon(
                              Icons.wc,
                              color: Colors.blue.shade400,
                              size: 18,
                            ),
                            tooltip: AppLocalizations.of(context)!.pauseToilet,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        // Cigarette
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () => onTogglePause('smoke'),
                            icon: Icon(
                              Icons.smoking_rooms,
                              color: Colors.grey.shade500,
                              size: 18,
                            ),
                            tooltip: AppLocalizations.of(context)!.pauseSmoke,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        // Puking/sick
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () => onTogglePause('sick'),
                            icon: Icon(
                              Icons.sick,
                              color: Colors.green.shade300,
                              size: 18,
                            ),
                            tooltip: AppLocalizations.of(context)!.pauseSick,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        // Love/sex
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () => onTogglePause('love'),
                            icon: Icon(
                              Icons.favorite,
                              color: Colors.pink.shade300,
                              size: 18,
                            ),
                            tooltip: AppLocalizations.of(context)!.pauseLove,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Right button - delete for active players, return for paused players
            if (!isPaused)
              Builder(
                builder: (context) => IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete),
                  color: Colors.red.shade400,
                  tooltip: AppLocalizations.of(context)!.remove,
                ),
              )
            else
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => onTogglePause(''),
                  icon: const Icon(Icons.near_me),
                  color: Colors.green.shade400,
                  tooltip: AppLocalizations.of(context)!.backToGame,
                ),
              ),
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
