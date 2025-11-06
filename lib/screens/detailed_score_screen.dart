import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game/dart_game.dart';
import '../game/shanghai.dart';
import '../widgets/chalk_tick_painter.dart';
import '../utils/game_provider.dart';
import 'main_menu_screen.dart';

class DetailedScoreScreen extends StatelessWidget {
  final DartGame game;
  final int gameMode; // 0 = 301, 1 = Cricket

  const DetailedScoreScreen({
    super.key,
    required this.game,
    required this.gameMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Top spacer
                const SizedBox(height: 20),

                // Score content
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.brown.shade600,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            'Spielstand',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade300,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Cricket grid or simple scores or Shanghai info
                          if (gameMode == 2)
                            _buildCricketGrid()
                          else if (gameMode == 3)
                            _buildShanghaiInfo()
                          else
                            _buildSimpleScores(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quit button at bottom
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () => _showQuitConfirmation(context),
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text(
                        'Spiel beenden',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Close button in top right
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                iconSize: 32,
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.brown.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuitConfirmation(BuildContext context) async {
    final shouldQuit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Spiel beenden?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Möchten Sie wirklich das Spiel beenden und zum Hauptmenü zurückkehren? Der aktuelle Spielstand geht verloren.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Abbrechen',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: const Text('Beenden'),
          ),
        ],
      ),
    );

    if (shouldQuit == true && context.mounted) {
      // Reset game and return to main menu
      context.read<GameProvider>().resetGame();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainMenuScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildSimpleScores() {
    final numPlayers = game.getNumberOfPlayers();

    return Column(
      children: [
        for (int i = 0; i < numPlayers; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  game.getPlayer(i).name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: game.getCurrentPlayer().playerNumber == i
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: game.getCurrentPlayer().playerNumber == i
                        ? Colors.yellow.shade600
                        : Colors.white,
                  ),
                ),
                Text(
                  '${game.getPlayer(i).getScore()}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: game.getCurrentPlayer().playerNumber == i
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: game.getCurrentPlayer().playerNumber == i
                        ? Colors.yellow.shade600
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildShanghaiInfo() {
    final numPlayers = game.getNumberOfPlayers();
    final shanghaiGame = game as Shanghai;

    return Column(
      children: [
        // Display current round info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade800,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                'Runde ${shanghaiGame.getCurrentRound()}/${shanghaiGame.getTotalRounds()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Aktuelles Ziel: ${shanghaiGame.getTargetNumber()}',
                style: TextStyle(fontSize: 16, color: Colors.orange.shade200),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Player scores
        for (int i = 0; i < numPlayers; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  game.getPlayer(i).name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: game.getCurrentPlayer().playerNumber == i
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: game.getCurrentPlayer().playerNumber == i
                        ? Colors.yellow.shade600
                        : Colors.white,
                  ),
                ),
                Text(
                  '${game.getPlayer(i).getScore()}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: game.getCurrentPlayer().playerNumber == i
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: game.getCurrentPlayer().playerNumber == i
                        ? Colors.yellow.shade600
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCricketGrid() {
    final numPlayers = game.getNumberOfPlayers();
    const fields = [15, 16, 17, 18, 19, 20, 25]; // BE = 25

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header row with field numbers
          Row(
            children: [
              const SizedBox(width: 100), // Space for player names
              for (int field in fields)
                Expanded(
                  child: Center(
                    child: Text(
                      field == 25 ? 'BE' : '$field',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Player rows
          for (int i = 0; i < numPlayers; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Player name and score
                  SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.getPlayer(i).name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                game.getCurrentPlayer().playerNumber == i
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: game.getCurrentPlayer().playerNumber == i
                                ? Colors.yellow.shade600
                                : Colors.white,
                          ),
                        ),
                        Text(
                          '${game.getPlayer(i).getScore()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Hit indicators for each field
                  for (int field in fields)
                    Expanded(
                      child: Center(
                        child: _buildCricketCell(field, game.getPlayer(i)),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCricketCell(int fieldValue, player) {
    final hits = game.getHits(fieldValue, player);
    final isClosed = game.getField(fieldValue).isClosed();

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: isClosed
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: hits > 0
            ? ChalkTicks(
                count: hits.clamp(0, 5),
                color: isClosed ? Colors.red.shade400 : Colors.white,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
