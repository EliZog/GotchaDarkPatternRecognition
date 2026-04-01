import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../widgets/booster_pack.dart';
import '../widgets/top_app_bar.dart';
import '../theme/app_theme.dart';
import '../widgets/discovery_dialog.dart';
import '../data/card_database.dart';
import '../models/card_model.dart';
import 'pack_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Container(
              color: AppTheme.background,
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const CustomTopAppBar(),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        _buildGoldenPackProgress(context),
                        const SizedBox(height: 40),
                        const BoosterPackWidget(
                          imageUrl: 'https://lh3.googleusercontent.com/aida/ADBb0uiD3NXLPtjMYn9FETNr8XrWTUCL7iHixWOaGdouL3b3xk3emTROoA0xncU6SquD6YTFV-0OgmYD1fPK7WphB8mmRGP8uaVIER3f51BDykTOqGGS14PjLD3U1os01KjSyWJs4Hp7qysuT8Hvkh4LbIr97w9hAZFeoupKZn0HCGaA6lNspri8kjCXnfccMrHC-7mK9k9BlhAme6LRPrmMQuEmI_RuHV_cksfGk6SxIIKfJJLItWUG5shc3fqQW1w6nYj_f2UcxSk2lA',
                          seriesName: 'ELDRITCH SERIES',
                          accentColor: AppTheme.primary,
                        ),
                        const SizedBox(height: 40),
                        _buildActionButtons(context),
                        const SizedBox(height: 32),
                        _buildQuickStats(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldenPackProgress(BuildContext context) {
    final gameState = context.watch<GameState>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GOLDEN CARD PACK',
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${gameState.goldenPackProgress}/20',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: gameState.goldenPackProgress / 20,
              minHeight: 12,
              backgroundColor: AppTheme.background,
              color: AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final gameState = context.read<GameState>();
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            if (gameState.packsAvailable > 0) {
              final card = CardDatabase.allCards.firstWhere((c) => c.id == 'dp6');
              if (gameState.unlockDarkPattern('dp6', card)) {
                await showDiscoveryDialog(context, card);
              }
              if (!context.mounted) return;
              
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PackSelectionScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No packs available! Watch an AD to refill.')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 64),
            backgroundColor: AppTheme.primary,
            elevation: 8,
            shadowColor: AppTheme.primaryDim,
          ).copyWith(
            elevation: MaterialStateProperty.all(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt, size: 28, color: AppTheme.background),
              SizedBox(width: 12),
              Text('OPEN PACK', style: TextStyle(color: AppTheme.background, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            // Dark Pattern Fake Urgency / Ad wall unlock
            final card = CardDatabase.allCards.firstWhere((c) => c.id == 'dp4');
            if (gameState.unlockDarkPattern('dp4', card)) {
              showDiscoveryDialog(context, card);
            } else {
              gameState.addPacks(3);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Ad watched. 3 Packs added! (Simulation)',
                    style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: AppTheme.surfaceContainerHighest,
                ),
              );
            }
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            side: BorderSide(color: AppTheme.onSurfaceVariant.withOpacity(0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.play_circle_fill, color: AppTheme.secondary),
                  SizedBox(width: 12),
                  Text('Watch AD to refill', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('+3', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final gameState = context.watch<GameState>();
    return Row(
      children: [
        Expanded(
          child: _buildStatItem('Mythic Patterns', '${gameState.collection.where((c) => c.rarity == Rarity.mythic).length}/4', AppTheme.primary, Icons.psychology_alt),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatItem('Cards Owned', '${gameState.collection.length}/${CardDatabase.allCards.length}', AppTheme.secondary, Icons.auto_awesome),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF201A61).withOpacity(0.3)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 32) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 32) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
