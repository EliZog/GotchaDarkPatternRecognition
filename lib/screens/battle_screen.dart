import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;
import '../providers/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/top_app_bar.dart';
import '../widgets/gacha_card_widget.dart';
import '../models/card_model.dart';
import 'dart:async';

enum BattlePhase { entry, drafting, animatingDraft, battling, results }

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  BattlePhase _phase = BattlePhase.entry;
  
  List<GachaCard> _playerDeck = [];
  List<GachaCard> _aiDeck = [];
  List<GachaCard> _draftChoices = [];
  GachaCard? _selectedDraftCard;
  
  int _playerHP = 0;
  int _aiHP = 0;
  bool _playerTurn = true;
  String _combatLog = "";
  String? _battleResult;
  bool _isAttacking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = context.read<GameState>();
      final collection = gameState.collection;
      
      if (collection.length >= 2) {
        if (gameState.energy < 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not enough Energy to battle! (Need 5)'), backgroundColor: AppTheme.error),
          );
          Navigator.pop(context);
          return;
        }
        
        // Deduct stamina upon entry
        gameState.spendEnergy(5);

        if (collection.length == 2) {
          _playerDeck = List.from(collection);
          _generateAIDeck();
          _startCombat();
        } else {
          setState(() => _phase = BattlePhase.drafting);
          _rollDraftChoices();
        }
      }
    });
  }

  void _rollDraftChoices() {
    final collection = context.read<GameState>().collection;
    final random = math.Random();
    List<GachaCard> available = collection.where((c) => !_playerDeck.contains(c)).toList();
    available.shuffle(random);
    
    setState(() {
      _draftChoices = available.take(2).toList();
      _phase = BattlePhase.drafting;
    });
  }

  void _selectDraftCard(GachaCard card) {
    if (_phase != BattlePhase.drafting) return;
    
    setState(() {
      _selectedDraftCard = card;
      _phase = BattlePhase.animatingDraft;
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _playerDeck.add(card);
        _selectedDraftCard = null;
      });
      
      // If final card, wait an extra bit for clarity before fading out
      final bool isFinalCard = _playerDeck.length == 2;
      Future.delayed(Duration(milliseconds: isFinalCard ? 1000 : 400), () {
        if (!mounted) return;
        setState(() {
          if (isFinalCard) {
            _generateAIDeck();
            _startCombat();
          } else {
            _rollDraftChoices();
          }
        });
      });
    });
  }

  void _generateAIDeck() {
    final collection = context.read<GameState>().collection;
    int playerMythicCount = _playerDeck.where((c) => c.rarity == Rarity.mythic).length;
    int targetAIMythics = 0;

    if (playerMythicCount == 1) {
      targetAIMythics = math.Random().nextBool() ? 1 : 0;
    } else if (playerMythicCount == 2) {
      targetAIMythics = 2;
    }

    List<GachaCard> mythicsPool = collection.where((c) => c.rarity == Rarity.mythic).toList();
    List<GachaCard> othersPool = collection.where((c) => c.rarity != Rarity.mythic).toList();
    
    mythicsPool.shuffle();
    othersPool.shuffle();

    List<GachaCard> deck = [];
    deck.addAll(mythicsPool.take(targetAIMythics));
    int remaining = 2 - deck.length;
    
    // If we don't have enough mythics in pool, fallback to others
    if (remaining > 0) {
      deck.addAll(othersPool.take(remaining));
    }
    // Extreme edge fallback
    if (deck.length < 2) deck.addAll(collection.take(2 - deck.length));

    _aiDeck = deck;
  }

  void _startCombat() {
    setState(() {
      _phase = BattlePhase.battling;
      _playerHP = _playerDeck.isNotEmpty ? _playerDeck.first.defense : 0;
      _aiHP = _aiDeck.isNotEmpty ? _aiDeck.first.defense : 0;
      _playerTurn = true;
      _combatLog = "Battle Commences! Player strikes first.";
    });
    
    Future.delayed(const Duration(seconds: 2), _executeTurn);
  }

  void _executeTurn() async {
    if (_phase != BattlePhase.battling) return;

    setState(() => _isAttacking = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Attack windup
    
    setState(() {
      _isAttacking = false;
      if (_playerTurn) {
        int dmg = _playerDeck.first.attack;
        _aiHP -= dmg;
        _combatLog = "You dealt $dmg damage!";
        if (_aiHP <= 0) {
          _aiDeck.removeAt(0);
          if (_aiDeck.isNotEmpty) {
            _aiHP = _aiDeck.first.defense;
            _combatLog = "AI switched to next card!";
          } else {
            _endBattle(true);
            return;
          }
        }
      } else {
        int dmg = _aiDeck.first.attack;
        _playerHP -= dmg;
        _combatLog = "AI dealt $dmg damage!";
        if (_playerHP <= 0) {
          _playerDeck.removeAt(0);
          if (_playerDeck.isNotEmpty) {
            _playerHP = _playerDeck.first.defense;
            _combatLog = "Your card was defeated. Next card in!";
          } else {
            _endBattle(false);
            return;
          }
        }
      }
      _playerTurn = !_playerTurn;
    });

    if (_phase == BattlePhase.battling) {
      Future.delayed(const Duration(seconds: 2), _executeTurn);
    }
  }

  void _endBattle(bool playerWon) {
    setState(() {
      _phase = BattlePhase.results;
      _battleResult = playerWon ? "VICTORY" : "DEFEAT";
    });
    
    if (playerWon) {
      context.read<GameState>().addPacks(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final collection = gameState.collection;
    final bool canFight = collection.length >= 2;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const CustomTopAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (!canFight) ...[
                      const Spacer(),
                      _buildInsufficientCardsOverlay(),
                      const Spacer(),
                    ] else ...[
                      if (_phase == BattlePhase.drafting || _phase == BattlePhase.animatingDraft)
                        Expanded(child: _buildDraftPhase()),
                      
                      if (_phase == BattlePhase.battling || _phase == BattlePhase.results)
                        Expanded(child: _buildCombatArena()),
                    ],
                    
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('RETURN HOME', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsufficientCardsOverlay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.error.withOpacity(0.5), width: 2),
      ),
      child: const Column(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 64),
          SizedBox(height: 16),
          Text(
            "NOT ENOUGH CARDS",
            style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2),
          ),
          SizedBox(height: 8),
          Text(
            "You don't have enough cards to enter battle mode.\nYou need at least 2 cards.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftPhase() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.skullCrossbones, color: AppTheme.secondary, size: 28),
            const SizedBox(width: 16),
            const Text(
              "DRAFT PHASE",
              style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 4),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text("Swipe to view options • Select Card ${_playerDeck.length + 1} / 2", style: const TextStyle(color: AppTheme.onSurfaceVariant)),
        const Spacer(),
        
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _draftChoices.map((card) {
              final isSelected = _selectedDraftCard == card;
              final isUnselected = _phase == BattlePhase.animatingDraft && !isSelected;
              
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _phase == BattlePhase.drafting ? () => _selectDraftCard(card) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      transform: Matrix4.identity()
                        ..translate(0.0, isSelected ? 20.0 : 0.0)
                        ..scale(isSelected ? 1.05 : (isUnselected ? 0.9 : 1.0)),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isUnselected ? 0.0 : 1.0,
                        child: Hero(
                          tag: 'draft_${card.id}',
                          child: IgnorePointer(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: GachaCardWidget(
                                card: card,
                                width: 320,
                                height: 480,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
          
        const Spacer(),
        // Deck display
        Container(
          height: 140, // Expanded height for deck size!
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (index) {
              if (index < _playerDeck.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: 80, // Expanded width for deck!
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: GachaCardWidget(
                        card: _playerDeck[index],
                        width: 200,
                        height: 300,
                        showStats: false,
                        isMini: true,
                      ),
                    ),
                  ),
                );
              } else {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 80,
                  height: 115,
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    border: Border.all(color: AppTheme.onSurfaceVariant.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildCombatArena() {
    if (_phase == BattlePhase.results) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _battleResult!,
            style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(
              color: _battleResult == 'VICTORY' ? AppTheme.secondary : AppTheme.error,
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 24),
          if (_battleResult == 'VICTORY')
            const Text("+1 BOOSTER PACK EARNED", style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold)),
        ],
      );
    }

    final playerCard = _playerDeck.isNotEmpty ? _playerDeck.first : null;
    final aiCard = _aiDeck.isNotEmpty ? _aiDeck.first : null;

    return Column(
      children: [
        // AI Side
        if (aiCard != null)
           _buildArenaCardPair(aiCard, _aiHP, isAI: true),
        
        const Spacer(),
        // Log Box
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _playerTurn ? AppTheme.secondary.withOpacity(0.5) : AppTheme.error.withOpacity(0.5)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _combatLog,
              key: ValueKey(_combatLog),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Spacer(),

        // Player Side
        if (playerCard != null)
           _buildArenaCardPair(playerCard, _playerHP, isAI: false),
      ],
    );
  }

  Widget _buildArenaCardPair(GachaCard card, int hp, {required bool isAI}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.translationValues(0, _isAttacking && (_playerTurn != isAI) ? (isAI ? 20 : -20) : 0, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isAI ? "ENEMY" : "YOU", style: TextStyle(color: isAI ? AppTheme.error : AppTheme.secondary, fontWeight: FontWeight.w900)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.error),
                ),
                child: Text("HP: $hp", style: const TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GachaCardWidget(
            key: ValueKey('${isAI ? "ai" : "player"}_${card.id}'),
            card: card,
            width: 160,
            height: 240,
            showStats: true, // We want to see ATK and DEF
          ),
        ],
      ),
    );
  }
}
