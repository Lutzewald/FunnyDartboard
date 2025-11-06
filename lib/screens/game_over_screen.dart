import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/game_provider.dart';
import 'main_menu_screen.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

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
              final winner = gameProvider.winner;

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Trophy icon
                      Icon(
                        Icons.emoji_events,
                        size: 120,
                        color: Colors.yellow.shade600,
                      ),
                      const SizedBox(height: 40),

                      // Winner text
                      const Text(
                        'Gewinner!',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black54,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Winner name
                      if (winner != null)
                        Text(
                          winner.name,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),

                      const SizedBox(height: 40),

                      // All players' final scores
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.brown.shade600,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Endstand',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // List all players sorted by rank
                            ...() {
                              final game = gameProvider.currentGame;
                              if (game == null) return <Widget>[];

                              // Get all players and sort them
                              final players = List.generate(
                                game.getNumberOfPlayers(),
                                (index) => game.getPlayer(index),
                              );

                              // Sort based on game mode
                              // For countdown (301/501), lower score is better
                              // For Cricket/Shanghai, higher score is better
                              final isCountdown =
                                  gameProvider.selectedGameMode == 0 ||
                                  gameProvider.selectedGameMode == 1;

                              players.sort((a, b) {
                                if (isCountdown) {
                                  // Lower score wins (ascending order)
                                  return a.getScore().compareTo(b.getScore());
                                } else {
                                  // Higher score wins (descending order)
                                  return b.getScore().compareTo(a.getScore());
                                }
                              });

                              return players.map((player) {
                                final isWinner =
                                    winner?.playerNumber == player.playerNumber;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          if (isWinner)
                                            Icon(
                                              Icons.emoji_events,
                                              color: Colors.yellow.shade600,
                                              size: 24,
                                            ),
                                          if (isWinner)
                                            const SizedBox(width: 8),
                                          Text(
                                            player.name,
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: isWinner
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isWinner
                                                  ? Colors.yellow.shade600
                                                  : Colors.white,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${player.getScore()}',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: isWinner
                                              ? Colors.yellow.shade600
                                              : Colors.white,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            }(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Return to menu button
                      SizedBox(
                        width: 280,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            gameProvider.resetGame();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainMenuScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown.shade300,
                            foregroundColor: Colors.brown.shade900,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Hauptmenü',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
