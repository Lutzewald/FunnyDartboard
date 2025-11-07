import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/game_provider.dart';
import '../l10n/app_localizations.dart';
import 'game_screen.dart';

class CountdownOptionsScreen extends StatelessWidget {
  const CountdownOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.brown.shade800,
        title: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final gameMode = gameProvider.selectedGameMode == 0 ? '301' : '501';
            final l10n = AppLocalizations.of(context)!;
            return Text('$gameMode ${l10n.gameRules}');
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // IN Rules Section
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Column(
                          children: [
                            _buildSectionTitle(l10n.entry),
                            const SizedBox(height: 16),
                            _buildRuleGrid(
                              rules: [
                                (l10n.straight, 'straight'),
                                (l10n.double, 'double'),
                                (l10n.triple, 'triple'),
                                (l10n.master, 'master'),
                              ],
                              selectedValue: gameProvider.countdownInRule,
                              onSelected: (value) =>
                                  gameProvider.setCountdownInRule(value),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // OUT Rules Section
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Column(
                          children: [
                            _buildSectionTitle(l10n.exit),
                            const SizedBox(height: 16),
                            _buildRuleGrid(
                              rules: [
                                (l10n.straight, 'straight'),
                                (l10n.double, 'double'),
                                (l10n.triple, 'triple'),
                                (l10n.master, 'master'),
                              ],
                              selectedValue: gameProvider.countdownOutRule,
                              onSelected: (value) =>
                                  gameProvider.setCountdownOutRule(value),
                            ),
                          ],
                        );
                      },
                    ),

                    const Spacer(),

                    // Start button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          gameProvider.startGame();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GameScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.startGame,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRuleGrid({
    required List<(String, String)> rules,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Row(
      children: [
        for (int i = 0; i < rules.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _RuleButton(
              label: rules[i].$1,
              value: rules[i].$2,
              isSelected: selectedValue == rules[i].$2,
              onPressed: () => onSelected(rules[i].$2),
            ),
          ),
        ],
      ],
    );
  }
}

class _RuleButton extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onPressed;

  const _RuleButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Colors.brown.shade300
              : Colors.grey.shade800.withValues(alpha: 0.5),
          foregroundColor: isSelected
              ? Colors.brown.shade900
              : Colors.grey.shade300,
          elevation: isSelected ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Colors.brown.shade100 : Colors.grey.shade700,
              width: isSelected ? 3 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
