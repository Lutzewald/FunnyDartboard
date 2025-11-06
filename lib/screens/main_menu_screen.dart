import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/game_provider.dart';
import 'player_selection_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  'DartBoard',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black54,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),

                // 2x2 Grid of game modes
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      // First row: 301 and 501
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _GameModeButton(
                              label: '301',
                              onPressed: () {
                                context.read<GameProvider>().setGameMode(0);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PlayerSelectionScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _GameModeButton(
                              label: '501',
                              onPressed: () {
                                context.read<GameProvider>().setGameMode(1);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PlayerSelectionScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Second row: Cricket and Shanghai
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _GameModeButton(
                              label: 'Cricket',
                              onPressed: () {
                                context.read<GameProvider>().setGameMode(2);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PlayerSelectionScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _GameModeButton(
                              label: 'Shanghai',
                              onPressed: () {
                                context.read<GameProvider>().setGameMode(3);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PlayerSelectionScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Donation button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://www.paypal.me/lutzewald',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      icon: const Icon(Icons.favorite, size: 20),
                      label: const Text(
                        'Spende',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade400,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameModeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GameModeButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Make it square
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade300,
          foregroundColor: Colors.brown.shade900,
          elevation: 8,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
