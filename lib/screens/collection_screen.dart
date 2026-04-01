import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../models/card_model.dart';
import '../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/gacha_card_widget.dart';
import '../data/card_database.dart';
import '../widgets/discovery_dialog.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomTopAppBar(),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildStats(context, gameState),
                          const SizedBox(height: 16),
                          _buildProgressBar(gameState),
                          const SizedBox(height: 32),
                          _buildDarkPatternTypesSection(context, gameState),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 32,
                        mainAxisSpacing: 48,
                        childAspectRatio: 0.65,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final card = gameState.collection[index];
                          final count = gameState.getCardCount(card.id);
                          final isNew = gameState.isCardNew(card.id);
                          
                          return GestureDetector(
                            onTap: () {
                              context.read<GameState>().markCardViewed(card.id);
                              _showCardDetails(context, card);
                            },
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    GachaCardWidget(
                                      card: card,
                                      showStats: false,
                                      isNew: isNew,
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                    ),
                                    if (count > 1)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppTheme.secondary,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.5),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                            border: Border.all(color: Colors.white24, width: 1),
                                          ),
                                          child: Text(
                                            'x$count',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                        childCount: gameState.collection.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, GameState gameState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GLOBAL PROGRESS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant, letterSpacing: 2),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${gameState.collection.length}/${CardDatabase.allCards.length}',
                  style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 28, fontStyle: FontStyle.italic),
                ),
                const SizedBox(width: 8),
                const Text(
                  'CARDS FOUND',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                ),
              ],
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {
            // Dark Pattern: Share Profile Reward
            final card = CardDatabase.allCards.firstWhere((c) => c.id == 'dp5');
            if (gameState.unlockDarkPattern('dp5', card)) {
              showDiscoveryDialog(context, card);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile link copied to clipboard!')),
              );
            }
          },
          icon: const Icon(Icons.share, size: 16, color: AppTheme.secondary),
          label: const Text('Share Profile', style: TextStyle(fontSize: 12, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
          style: TextButton.styleFrom(
            backgroundColor: AppTheme.secondary.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(GameState gameState) {
    if (CardDatabase.allCards.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      height: 12,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.surfaceContainerHighest, width: 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (gameState.collection.length / CardDatabase.allCards.length).clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primaryDim, AppTheme.primary]),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkPatternTypesSection(BuildContext context, GameState gameState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DARK PATTERN TYPES',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: DarkPatternType.values.where((t) => t != DarkPatternType.unknown).map((type) {
            final isUnlocked = gameState.collection.any((c) => c.darkPatternType == type);
            
            return GestureDetector(
              onTap: () {
                final card = CardDatabase.allCards.firstWhere(
                  (c) => c.darkPatternType == type, 
                  orElse: () => GachaCard(
                    id: 'temp', 
                    title: 'Unknown', 
                    description: '', 
                    rarity: Rarity.common, 
                    type: CardType.darkPattern,
                    darkPatternType: type,
                    attack: 0,
                    defense: 0,
                    imageUrl: '',
                  ),
                );
                _showTypeDefinitionDialog(context, card);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isUnlocked ? AppTheme.surfaceContainerHighest : AppTheme.surfaceContainerLow,
                  border: Border.all(
                    color: isUnlocked ? AppTheme.primary.withOpacity(0.5) : AppTheme.onSurfaceVariant.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GachaCardWidget.buildDarkPatternIcon(
                      type, 
                      isUnlocked ? AppTheme.primary : AppTheme.onSurfaceVariant.withOpacity(0.5), 
                      16
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? AppTheme.primary : AppTheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showCardDetails(BuildContext context, GachaCard card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppTheme.primary, width: 4)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: GachaCardWidget(
                        card: card, 
                        width: 260, 
                        height: 400,
                        onInfoPressed: card.isDarkPattern ? () => _showTypeDefinitionDialog(context, card) : null,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(card.description, textAlign: TextAlign.center, style: AppTheme.darkTheme.textTheme.bodyLarge),
                    const SizedBox(height: 32),
                    if (card.isDarkPattern) ...[
                      _buildDarkPatternTypeHeader(context, card),
                      const SizedBox(height: 32),
                      _buildDarkPatternInfo('WHY IT WORKS', card.whyItWorks ?? ''),
                      const SizedBox(height: 24),
                      _buildDarkPatternInfo('SOLUTION', card.solution ?? '', isSolution: true),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                backgroundColor: AppTheme.surfaceContainerHighest,
              ),
              child: const Text('BACK'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkPatternTypeHeader(BuildContext context, GachaCard card) {
    final typeName = card.darkPatternType?.displayName.toUpperCase() ?? 'UNKNOWN TYPE';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceContainerHighest),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('TYPE: ', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Text(typeName, style: const TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  void _showTypeDefinitionDialog(BuildContext context, GachaCard card) {
    final typeName = card.darkPatternType?.displayName ?? 'Unknown Type';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('WHAT IS A TYPE?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type represents the category of dark pattern this card belongs to. Dark patterns are deceptive design tricks used in interfaces to make you do things you didn\'t mean to (like buying extra items or handing over data).',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                GachaCardWidget.buildDarkPatternIcon(card.darkPatternType, AppTheme.primary, 36),
                const SizedBox(width: 12),
                Expanded(child: Text(typeName, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 18))),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getDefinitionForType(card.darkPatternType),
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('GOT IT', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  String _getDefinitionForType(DarkPatternType? type) {
    if (type == null) return 'No definition available.';
    switch (type) {
      case DarkPatternType.comparisonPrevention: return 'Making it difficult for users to compare prices or features of different products.';
      case DarkPatternType.confirmshaming: return 'Guilting the user into opting into something by using emotional or manipulative language in the decline option.';
      case DarkPatternType.disguisedAds: return 'Advertisements that are disguised to look like regular content or navigation elements.';
      case DarkPatternType.fakeScarcity: return 'Falsely claiming that a product is in limited supply to pressure users into a quick purchase.';
      case DarkPatternType.fakeSocialProof: return 'Using fake reviews, testimonials, or activity notifications to create a false sense of popularity.';
      case DarkPatternType.fakeUrgency: return 'Creating an artificial deadline or countdown timer to rush users into making a decision.';
      case DarkPatternType.forcedAction: return 'Requiring the user to perform a specific, unrelated action to access a core feature.';
      case DarkPatternType.hardToCancel: return 'Making the cancellation process excessively complex, frustrating, or time-consuming.';
      case DarkPatternType.hiddenCosts: return 'Revealing unexpected charges, fees, or taxes only at the very final step of the checkout process.';
      case DarkPatternType.hiddenSubscription: return 'Tricking users into a recurring subscription disguised as a one-time payment or free trial.';
      case DarkPatternType.nagging: return 'Repeatedly interrupting the user with requests to perform an action they have already dismissed.';
      case DarkPatternType.obstruction: return 'Making a specific action significantly harder than it needs to be to discourage users from doing it.';
      case DarkPatternType.preselection: return 'Pre-selecting checkboxes or options that benefit the service, assuming consent by default.';
      case DarkPatternType.sneaking: return 'Adding additional items into the user\'s basket or making unrequested changes without explicit consent.';
      case DarkPatternType.trickWording: return 'Using confusing or double-negative language to trick users into agreeing to something they wouldn\'t otherwise.';
      case DarkPatternType.visualInterference: return 'Using visual design (color, size, placement) to hide or disguise important information or options.';
      case DarkPatternType.unknown: return 'Classification pending.';
    }
  }

  Widget _buildDarkPatternInfo(String title, String content, {bool isSolution = false}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSolution ? AppTheme.secondary : AppTheme.onSurface,
            fontWeight: isSolution ? FontWeight.bold : FontWeight.normal,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
