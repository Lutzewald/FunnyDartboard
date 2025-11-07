import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/game_provider.dart';
import '../utils/dartboard_calculator.dart';
import '../widgets/dartboard_painter.dart';
import '../models/player.dart';
import '../game/shanghai.dart';
import '../l10n/app_localizations.dart';
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
    _zoomAnimation = Tween<double>(begin: 1.0, end: 3.5).animate(
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

      const zoomFactor = 3.5;
      final edgeMargin = boardSize.width * 0.15; // 15% of screen width

      // Calculate offset to keep tap position centered
      final centerX = boardSize.width / 2;
      final centerY = boardSize.height / 2;
      
      // Desired offset to center the tap position
      double offsetX = (centerX - tapPosition.dx) * (zoomFactor - 1);
      double offsetY = (centerY - tapPosition.dy) * (zoomFactor - 1);

      // Calculate horizontal thirds
      final leftThirdBoundary = boardSize.width / 3;
      final rightThirdBoundary = boardSize.width * 2 / 3;

      // Add margin shift based on which horizontal third was tapped
      if (tapPosition.dx < leftThirdBoundary) {
        // Tapped on left third - shift view to the right
        offsetX += edgeMargin;
      } else if (tapPosition.dx > rightThirdBoundary) {
        // Tapped on right third - shift view to the left
        offsetX -= edgeMargin;
      }
      // Center third: no horizontal shift
      
      if (tapPosition.dy < centerY) {
        // Tapped on top half - shift view down
        offsetY += edgeMargin;
      } else {
        // Tapped on bottom half - shift view up
        offsetY -= edgeMargin;
      }

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

  String _getNextPlayerLabel(BuildContext context, GameProvider gameProvider) {
    final game = gameProvider.currentGame;
    final l10n = AppLocalizations.of(context)!;
    if (game == null) return l10n.continue_;

    final numPlayers = game.getNumberOfPlayers();
    
    // Single player: show "Weiter"
    if (numPlayers == 1) {
      return l10n.continue_;
    }

    // Multiple players: show next player's name
    final currentPlayerIndex = game.getCurrentPlayer().playerNumber;
    final nextPlayerIndex = (currentPlayerIndex + 1) % numPlayers;
    final nextPlayer = game.getPlayer(nextPlayerIndex);

    return nextPlayer.name;
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
              Text(
                AppLocalizations.of(context)!.target,
                style: const TextStyle(
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
                '${AppLocalizations.of(context)!.round} $currentRound/$totalRounds',
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
    final field = game.getField(fieldValue);
    final isOpenByPlayer = field.isOpenByPlayer(currentPlayer);

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          // Show badge if field is closed or opened, otherwise show ticks
          SizedBox(
            height: 26,
            child: _buildCricketFieldIndicator(hits, isClosed, isOpenByPlayer),
          ),
        ],
      ),
    );
  }

  Widget _buildCricketFieldIndicator(int hits, bool isClosed, bool isOpenByPlayer) {
    // If field is closed, show red badge with lock icon
    if (isClosed) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.lock,
            color: Colors.white,
            size: 14,
          ),
        ),
      );
    }

    // If field is opened (3+ hits), show green badge with checkmark
    if (isOpenByPlayer && hits >= 3) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 14,
          ),
        ),
      );
    }

    // Show orange dots for 1-2 hits
    if (hits > 0) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.circle,
                color: Colors.white,
                size: 8,
              ),
              if (hits >= 2) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.circle,
                  color: Colors.white,
                  size: 8,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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

    // Handle different player counts
    if (numPlayers == 1) {
      // Only 1 player: show current player centered
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _buildPlayerScore(
              player: currentPlayer,
              fontSize: 20,
              isCurrent: true,
            ),
          ),
        ],
      );
    } else if (numPlayers == 2) {
      // 2 players: empty left, current center, next right
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Empty space on left
          const Expanded(child: SizedBox.shrink()),

          // Current player (center, larger)
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
    } else {
      // 3+ players: previous left, current center, next right
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
    final isCricket = gameProvider.selectedGameMode == 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final arrow = arrows[index];

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

        final multiplier = arrow.getMultiplier();
        final number = arrow.getNumber();
        final score = arrow.getScore();

        // Cricket mode: special handling for valuable fields
        if (isCricket && multiplier > 0) {
          final isValuableField = (number >= 15 && number <= 20) || number == 25;
          
          if (isValuableField) {
            if (score > 0) {
              // Scored points: show the value
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
                      '$score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // Check if this is the arrow that opened the field
              // Find the last arrow in this turn that hit this field with score=0
              int lastArrowWithSameField = -1;
              for (int i = 0; i < arrows.length; i++) {
                final a = arrows[i];
                if (a != null && a.getNumber() == number && a.getMultiplier() > 0 && a.getScore() == 0) {
                  lastArrowWithSameField = i;
                }
              }
              
              // Check if field is now opened
              final currentPlayer = gameProvider.currentPlayer;
              final field = game.getField(number);
              final isFieldOpened = currentPlayer != null && field.isOpenByPlayer(currentPlayer);
              
              // Show checkmark only on the last arrow that opened the field
              if (isFieldOpened && index == lastArrowWithSameField) {
                // Field just opened by this arrow: show green checkmark
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                );
              } else {
                // Hit valuable field but not yet opened or earlier hit: show orange dot
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 50,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                );
              }
            }
          }
        }

        // Show X for invalid throws (score = 0)
        if (score == 0) {
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

        // Show throw value for valid throws in non-Cricket modes
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
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Zoom out button (if zoomed)
          if (_isZoomed)
            _ControlButton(
              label: l10n.back,
              icon: Icons.zoom_out,
              onPressed: _handleZoomOut,
            ),

          // Undo button
          if (!_isZoomed && gameProvider.canUndo)
            _ControlButton(
              label: l10n.undo,
              icon: Icons.undo,
              onPressed: () => gameProvider.undoLastThrow(),
            ),

          // Next player button
          if (!_isZoomed)
            _ControlButton(
              label: _getNextPlayerLabel(context, gameProvider),
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
    final l10n = AppLocalizations.of(context)!;
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.quitGameQuestion),
        content: Text(l10n.exitDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
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
            child: Text(l10n.quit),
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
