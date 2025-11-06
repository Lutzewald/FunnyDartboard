import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/game_provider.dart';
import '../utils/dartboard_calculator.dart';
import '../widgets/dartboard_painter.dart';
import '../widgets/chalk_tick_painter.dart';
import '../models/player.dart';
import '../game/shanghai.dart';
import 'game_over_screen.dart';
import 'main_menu_screen.dart';
import 'detailed_score_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final bool _showScore = true;
  bool _isZoomed = false;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _zoomAnimation = Tween<double>(begin: 1.0, end: 2.5).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );
    _offsetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  void _handleZoomIn(Offset tapPosition, Size boardSize) {
    setState(() {
      _isZoomed = true;

      // Calculate offset to keep tap position centered
      final centerX = boardSize.width / 2;
      final centerY = boardSize.height / 2;
      final offsetX = (centerX - tapPosition.dx) * 1.5;
      final offsetY = (centerY - tapPosition.dy) * 1.5;

      _offsetAnimation =
          Tween<Offset>(
            begin: Offset.zero,
            end: Offset(offsetX, offsetY),
          ).animate(
            CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
          );

      _zoomController.forward();
    });
  }

  void _handleZoomOut() {
    _zoomController.reverse().then((_) {
      setState(() {
        _isZoomed = false;
      });
    });
  }

  String _getNextPlayerLabel(GameProvider gameProvider) {
    final game = gameProvider.currentGame;
    if (game == null) return 'Nächster';

    final currentPlayerIndex = game.getCurrentPlayer().playerNumber;
    final nextPlayerIndex =
        (currentPlayerIndex + 1) % game.getNumberOfPlayers();
    final nextPlayer = game.getPlayer(nextPlayerIndex);

    return 'Nächster: ${nextPlayer.name}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _showExitDialog(context);
        }
      },
      child: Scaffold(
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
                // Check for game over
                if (gameProvider.isGameOver) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameOverScreen(),
                      ),
                    );
                  });
                }

                return Stack(
                  children: [
                    // Main game area
                    Column(
                      children: [
                        // Spacer for score display
                        if (_showScore) const SizedBox(height: 200),

                        // Dartboard
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final boardSize = constraints.maxWidth;
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTapDown: (details) {
                                      if (_isZoomed) {
                                        // Second tap - throw dart
                                        _handleDartThrow(
                                          gameProvider,
                                          details.localPosition,
                                          boardSize,
                                        );
                                      } else {
                                        // First tap - zoom in
                                        _handleZoomIn(
                                          details.localPosition,
                                          Size(boardSize, boardSize),
                                        );
                                      }
                                    },
                                    child: AnimatedBuilder(
                                      animation: _zoomController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: _offsetAnimation.value,
                                          child: Transform.scale(
                                            scale: _zoomAnimation.value,
                                            child: CustomPaint(
                                              size: Size(boardSize, boardSize),
                                              painter: DartboardPainter(
                                                arrows:
                                                    gameProvider.currentGame
                                                        ?.getArrows() ??
                                                    [],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Control buttons
                        _buildControls(gameProvider),
                      ],
                    ),

                    // Score display overlay (tappable to show detailed scores)
                    if (_showScore)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _buildScoreDisplay(gameProvider),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(GameProvider gameProvider) {
    final game = gameProvider.currentGame;
    if (game == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        if (gameProvider.currentGame != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailedScoreScreen(
                game: gameProvider.currentGame!,
                gameMode: gameProvider.selectedGameMode,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Invalid throw markers at top
            _buildInvalidThrowMarkers(gameProvider),

            const SizedBox(height: 16),

            // Shanghai target display
            if (gameProvider.selectedGameMode == 3)
              _buildShanghaiTarget(gameProvider),

            // Cricket hits display
            if (gameProvider.selectedGameMode == 2)
              _buildCricketHits(gameProvider),

            // Player scores
            _buildPlayerScores(gameProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildShanghaiTarget(GameProvider gameProvider) {
    final game = gameProvider.currentGame;
    if (game == null || game is! Shanghai) return const SizedBox.shrink();

    final targetNumber = game.getTargetNumber();
    final currentRound = game.getCurrentRound();
    final totalRounds = game.getTotalRounds();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.shade800,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.orange.shade400, width: 2),
          ),
          child: Column(
            children: [
              const Text(
                'Ziel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$targetNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Runde $currentRound/$totalRounds',
                style: TextStyle(color: Colors.orange.shade200, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCricketHits(GameProvider gameProvider) {
    final game = gameProvider.currentGame;
    final currentPlayer = gameProvider.currentPlayer;
    if (game == null || currentPlayer == null) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int fieldValue = 15; fieldValue <= 20; fieldValue++)
              _buildCricketField(gameProvider, fieldValue),
            _buildCricketField(gameProvider, 25),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCricketField(GameProvider gameProvider, int fieldValue) {
    final game = gameProvider.currentGame;
    final currentPlayer = gameProvider.currentPlayer;
    if (game == null || currentPlayer == null) return const SizedBox.shrink();

    final hits = gameProvider.getHits(fieldValue, currentPlayer);
    final isClosed = game.getField(fieldValue).isClosed();

    return Column(
      children: [
        Text(
          fieldValue == 25 ? 'BE' : '$fieldValue',
          style: TextStyle(
            color: isClosed ? Colors.red.shade400 : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        // Use chalk ticks instead of dots
        SizedBox(
          height: 20,
          child: hits > 0
              ? ChalkTicks(
                  count: hits.clamp(0, 5),
                  color: isClosed ? Colors.red.shade400 : Colors.white,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPlayerScores(GameProvider gameProvider) {
    final game = gameProvider.currentGame;
    if (game == null) return const SizedBox.shrink();

    final numPlayers = game.getNumberOfPlayers();
    final currentPlayerIndex = gameProvider.currentPlayer?.playerNumber ?? 0;

    // Calculate indices for previous, current, and next players
    final previousIndex = (currentPlayerIndex - 1 + numPlayers) % numPlayers;
    final nextIndex = (currentPlayerIndex + 1) % numPlayers;

    final previousPlayer = game.getPlayer(previousIndex);
    final currentPlayer = game.getPlayer(currentPlayerIndex);
    final nextPlayer = game.getPlayer(nextIndex);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Previous player (left)
        Expanded(
          child: _buildPlayerScore(
            player: previousPlayer,
            fontSize: 14,
            isCurrent: false,
          ),
        ),

        // Current player (middle, larger)
        Expanded(
          child: _buildPlayerScore(
            player: currentPlayer,
            fontSize: 20,
            isCurrent: true,
          ),
        ),

        // Next player (right)
        Expanded(
          child: _buildPlayerScore(
            player: nextPlayer,
            fontSize: 14,
            isCurrent: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerScore({
    required Player player,
    required double fontSize,
    required bool isCurrent,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          player.name,
          style: TextStyle(
            color: isCurrent ? Colors.yellow.shade300 : Colors.grey.shade400,
            fontSize: fontSize,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '${player.getScore()}',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize + 2,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInvalidThrowMarkers(GameProvider gameProvider) {
    final game = gameProvider.currentGame;
    if (game == null) return const SizedBox.shrink();

    final arrows = game.getArrows();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final arrow = arrows[index];

        // Show X for invalid throws (score = 0 but arrow exists)
        if (arrow != null && arrow.getScore() == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 50,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'X',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }

        // Show dash for unfilled slots
        if (arrow == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: 50,
              height: 24,
              child: Center(
                child: Text(
                  '-',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }

        // Show throw value for valid throws (e.g., "3x20", "18", "2x5")
        final multiplier = arrow.getMultiplier();
        final number = arrow.getNumber();
        final displayText = multiplier == 1
            ? '$number'
            : '${multiplier}x$number';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 50,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                displayText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildControls(GameProvider gameProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Zoom out button (if zoomed)
          if (_isZoomed)
            _ControlButton(
              label: 'Zurück',
              icon: Icons.zoom_out,
              onPressed: _handleZoomOut,
            ),

          // Undo button
          if (!_isZoomed && gameProvider.canUndo)
            _ControlButton(
              label: 'Rückgängig',
              icon: Icons.undo,
              onPressed: () => gameProvider.undoLastThrow(),
            ),

          // Next player button
          if (!_isZoomed)
            _ControlButton(
              label: _getNextPlayerLabel(gameProvider),
              icon: Icons.arrow_forward,
              onPressed: () => gameProvider.nextPlayer(),
            ),
        ],
      ),
    );
  }

  void _handleDartThrow(
    GameProvider gameProvider,
    Offset tapPosition,
    double boardSize,
  ) {
    // Account for zoom and offset to get original dartboard coordinates
    final scale = _zoomAnimation.value;
    final offset = _offsetAnimation.value;

    // Transform tap position back to original dartboard coordinates
    // Reverse the transformations: first undo translate, then undo scale
    final centerX = boardSize / 2;
    final centerY = boardSize / 2;

    // Undo the translation
    final translatedX = tapPosition.dx - offset.dx;
    final translatedY = tapPosition.dy - offset.dy;

    // Undo the scale (relative to center)
    final adjustedX = (translatedX - centerX) / scale + centerX;
    final adjustedY = (translatedY - centerY) / scale + centerY;

    final boardRadius = boardSize / 2;

    final hit = DartboardCalculator.calculateHit(
      adjustedX,
      adjustedY,
      centerX,
      centerY,
      boardRadius,
    );

    // Normalize coordinates to 0-1 range
    final normalizedX = adjustedX / boardSize;
    final normalizedY = adjustedY / boardSize;

    gameProvider.throwDart(normalizedX, normalizedY, hit);

    // Zoom out after throwing
    _handleZoomOut();
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spiel beenden?'),
        content: const Text('Möchten Sie wirklich zum Hauptmenü zurückkehren?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              context.read<GameProvider>().resetGame();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                (route) => false,
              );
            },
            child: const Text('Beenden'),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade300,
          foregroundColor: Colors.brown.shade900,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
