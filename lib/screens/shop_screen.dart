import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/discovery_dialog.dart';
import '../data/card_database.dart';
import '../widgets/booster_pack.dart';
import 'pack_selection_screen.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMembershipBanner(context),
                    const SizedBox(height: 32),
                    _buildSectionHeader('FLASH DEALS', timer: '04:59:12'),
                    const SizedBox(height: 16),
                    _buildFlashDealCard(context),
                    const SizedBox(height: 32),
                    _buildSectionHeader('BOOSTER PACKS'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PackSelectionScreen()),
                              );
                            },
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: BoosterPackWidget(
                                imageUrl: '',
                                seriesName: 'Instagram Pack',
                                accentColor: Colors.pinkAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PackSelectionScreen()),
                              );
                            },
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: BoosterPackWidget(
                                imageUrl: '',
                                seriesName: 'Candy Crush Pack',
                                accentColor: Colors.pink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    _buildSectionHeader('ELITE COLLECTION'),
                    const SizedBox(height: 16),
                    _buildElitePack(context),
                    const SizedBox(height: 32),
                    _buildInfoBanner(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipBanner(BuildContext context) {
    final gameState = context.read<GameState>();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.surfaceContainerHighest, AppTheme.surfaceContainerLow],
        ),
        borderRadius: BorderRadius.circular(24),
        border: const Border(left: BorderSide(color: AppTheme.secondary, width: 4)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.workspace_premium, size: 120, color: AppTheme.secondary.withOpacity(0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VOID MEMBERSHIP',
                style: TextStyle(color: AppTheme.secondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 4),
              Text('JOIN THE DARK SIDE', style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(color: AppTheme.onSurface)),
              const SizedBox(height: 8),
              const Text(
                'Unlock daily dark packs and exclusive eldritch skins.',
                style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final card = CardDatabase.allCards.firstWhere((c) => c.id == 'dp1');
                  if (gameState.unlockDarkPattern('dp1', card)) {
                    showDiscoveryDialog(context, card);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: AppTheme.background,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('CLAIM POWER'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? timer}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(color: AppTheme.primary)),
        if (timer != null)
          Row(
            children: [
              const Icon(Icons.alarm, color: AppTheme.error, size: 14),
              const SizedBox(width: 4),
              Text(
                'ENDS IN: $timer',
                style: const TextStyle(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFlashDealCard(BuildContext context) {
    final gameState = context.read<GameState>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.error.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: const BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16)),
              ),
              child: const Text('80% VALUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ),
          Row(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.onSurfaceVariant.withOpacity(0.3)),
                ),
                child: const Icon(Icons.auto_fix_high, size: 48, color: AppTheme.error),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gacha Starter Kit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Text('Unlock exclusive Mythic pattern.', style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final card = CardDatabase.allCards.firstWhere((c) => c.id == 'dp2');
                        if (gameState.unlockDarkPattern('dp2', card)) {
                          showDiscoveryDialog(context, card);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error,
                        minimumSize: const Size(double.infinity, 36),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('CLAIM DEAL'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElitePack(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.secondary, width: 2),
        boxShadow: [
          BoxShadow(color: AppTheme.secondary.withOpacity(0.05), blurRadius: 20, spreadRadius: -5),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.auto_awesome, size: 96, color: AppTheme.secondary),
              Positioned(
                top: 0,
                right: -20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('RECOMMENDED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('ELITE DARK PACK', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          const Text('GUARANTEED LEGENDARY', style: TextStyle(color: AppTheme.secondaryDim, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text('BUY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'All pack odds are audited by the Void Council. Pity timer active: 5 more Elite Dark Packs for a Guaranteed Mythic card.',
              style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
