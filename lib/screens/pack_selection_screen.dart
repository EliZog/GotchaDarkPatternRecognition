import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/booster_pack.dart';
import '../data/card_database.dart';
import '../models/card_model.dart';
import '../widgets/gacha_card_widget.dart';
import 'dart:ui';

enum PackFlowState { selecting, zooming, ripping, extracting, revealing }

class PackDescriptor {
  final String id;
  final String name;
  final Color color;
  final String imageUrl;

  PackDescriptor({
    required this.id,
    required this.name,
    required this.color,
    required this.imageUrl,
  });
}

class PackSelectionScreen extends StatefulWidget {
  const PackSelectionScreen({super.key});

  @override
  State<PackSelectionScreen> createState() => _PackSelectionScreenState();
}

class _PackSelectionScreenState extends State<PackSelectionScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  PackFlowState _flowState = PackFlowState.selecting;
  
  // Transition/Opening State
  double _ripProgress = 0.0;
  late AnimationController _extractController;
  List<GachaCard>? _revealedCards;
  int _currentRevealIndex = 0;
  late PageController _revealPageController;
  late AnimationController _revealFadeController;

  final List<PackDescriptor> _packs = [
    PackDescriptor(
      id: 'eldritch',
      name: 'ELDRITCH SERIES',
      color: AppTheme.primary,
      imageUrl: 'https://lh3.googleusercontent.com/aida/ADBb0uiD3NXLPtjMYn9FETNr8XrWTUCL7iHixWOaGdouL3b3xk3emTROoA0xncU6SquD6YTFV-0OgmYD1fPK7WphB8mmRGP8uaVIER3f51BDykTOqGGS14PjLD3U1os01KjSyWJs4Hp7qysuT8Hvkh4LbIr97w9hAZFeoupKZn0HCGaA6lNspri8kjCXnfccMrHC-7mK9k9BlhAme6LRPrmMQuEmI_RuHV_cksfGk6SxIIKfJJLItWUG5shc3fqQW1w6nYj_f2UcxSk2lA',
    ),
    PackDescriptor(
      id: 'instagram',
      name: 'INSTAGRAM PACK',
      color: Colors.pinkAccent,
      imageUrl: '',
    ),
    PackDescriptor(
      id: 'candy_crush',
      name: 'CANDY CRUSH PACK',
      color: Colors.pink,
      imageUrl: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7, initialPage: 0);
    _revealPageController = PageController(viewportFraction: 0.85);
    _revealFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _extractController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  }

  void _onPackSelected(PackDescriptor pack) {
    setState(() => _flowState = PackFlowState.zooming);
    
    // Zoom delay for transition feel
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _flowState = PackFlowState.ripping;
          _revealedCards = CardDatabase.generatePack(packType: pack.id);
        });
      }
    });
  }

  void _onRipPanUpdate(DragUpdateDetails details) {
    if (_flowState != PackFlowState.ripping) return;
    
    // Swipe RIGHT to rip the pack open
    setState(() {
      _ripProgress += details.delta.dx / 300;
      _ripProgress = _ripProgress.clamp(0.0, 1.0);
    });

    if (_ripProgress >= 0.98) {
      if (_flowState != PackFlowState.extracting) {
        setState(() => _flowState = PackFlowState.extracting);
        _extractController.forward().then((_) => _triggerReveal());
      }
    }
  }

  void _triggerReveal() {
    setState(() {
      _flowState = PackFlowState.revealing;
    });
    context.read<GameState>().openPack(_revealedCards!);
    _revealFadeController.forward();
  }

  void _finish() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final isSelecting = _flowState == PackFlowState.selecting;
    final isZooming = _flowState == PackFlowState.zooming;
    final isRipping = _flowState == PackFlowState.ripping;
    final isExtracting = _flowState == PackFlowState.extracting;
    final isRevealing = _flowState == PackFlowState.revealing;
    final selectedPack = _packs[_currentPage];

    // Show the interactive pack layer during zooming, ripping, and extracting
    final bool showPackLayer = isZooming || isRipping || isExtracting;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient - Integrated
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  isSelecting 
                    ? selectedPack.color.withOpacity(0.12) 
                    : showPackLayer ? selectedPack.color.withOpacity(0.15) : Colors.black,
                  Colors.black,
                ],
              ),
            ),
          ),

          // Main Carousel UI Layer
          if (!isRevealing)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: showPackLayer ? 0 : 1,
              child: IgnorePointer(
                ignoring: !isSelecting,
                child: _buildSelectionContent(gameState),
              ),
            ),

          // Integrated Zoom Pack & Rip/Extract Layer
          if (showPackLayer)
            Positioned.fill(
              child: _buildZoomAndRipLayer(selectedPack),
            ),

          // Reveal Layer
          if (isRevealing)
            Positioned.fill(
              child: _buildRevealOverlay(),
            ),

          // Back Button
          if (isSelecting)
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionContent(GameState gameState) {
    return Column(
      children: [
        const SizedBox(height: 80),
        const Text('CHOOSE YOUR PACK', style: TextStyle(letterSpacing: 4, fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white70)),
        const Spacer(),
        
        // CAROUSEL
        SizedBox(
          height: 480,
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _packs.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    }
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: Center(
                          child: BoosterPackWidget(
                            imageUrl: _packs[index].imageUrl,
                            seriesName: _packs[index].name,
                            accentColor: _packs[index].color,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        const Spacer(),
        _buildSelectionFooter(gameState),
      ],
    );
  }

  Widget _buildSelectionFooter(GameState gameState) {
    final pack = _packs[_currentPage];
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(pack.name, style: TextStyle(color: pack.color, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('PACKS REMAINING: ${gameState.packsAvailable}', style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: gameState.packsAvailable > 0 ? () => _onPackSelected(pack) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: pack.color,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('RIP OPEN THIS PACK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomAndRipLayer(PackDescriptor pack) {
    final bool isRipping = _flowState == PackFlowState.ripping;

    return GestureDetector(
      onPanUpdate: _onRipPanUpdate,
      onPanEnd: (_) {
        if (_ripProgress < 0.98 && _flowState == PackFlowState.ripping) setState(() => _ripProgress = 0.0);
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // THE SHADOW LAYER (Renders at the very bottom)
          AnimatedBuilder(
            key: const ValueKey('PackShadowLayer'),
            animation: _extractController,
            builder: (context, child) {
              final double progress = Curves.easeInQuint.transform(_extractController.value);
              return Transform.translate(
                offset: Offset(0, progress * 800),
                child: TweenAnimationBuilder<double>(
                  key: const ValueKey('PackShadowZoomTween'),
                  tween: Tween(begin: 1.0, end: 1.25),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 280,
                        height: 440,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: pack.color.withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: -10,
                              offset: const Offset(0, 20),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // REVEALED CARD SLIDING UP (Renders directly above shadow)
          if (_revealedCards != null && _revealedCards!.isNotEmpty)
            AnimatedBuilder(
              key: const ValueKey('RevealedCardLayer'),
              animation: _extractController,
              builder: (context, child) {
                final double progress = Curves.easeOutCubic.transform(_extractController.value);
                return Transform.translate(
                  offset: Offset(0, -progress * 150),
                  child: Transform.scale(
                    scale: 1.1,
                    child: Opacity(
                      opacity: (progress * 2).clamp(0.0, 1.0),
                      child: GachaCardWidget(
                        card: _revealedCards![0], 
                        width: 300, 
                        height: 460, 
                        showStats: false,
                        isNew: context.read<GameState>().isCardNew(_revealedCards![0].id),
                      ),
                    ),
                  ),
                );
              },
            ),

          // THE SLIDING PACK (Without shadow so card emerges underneath it)
          AnimatedBuilder(
            key: const ValueKey('PackLayer'),
            animation: _extractController,
            builder: (context, child) {
              final double progress = Curves.easeInQuint.transform(_extractController.value);
              return Transform.translate(
                offset: Offset(0, progress * 800),
                child: TweenAnimationBuilder<double>(
                  key: const ValueKey('PackZoomTween'),
                  tween: Tween(begin: 1.0, end: 1.25),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: BoosterPackWidget(
                        imageUrl: pack.imageUrl,
                        seriesName: pack.name,
                        accentColor: pack.color,
                        ripProgress: _ripProgress,
                        hasDropShadow: false,
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // RIP HINT (Only shows when ripping state reached)
          if (isRipping)
            Positioned(
              key: const ValueKey('RipHintLayer'),
              top: MediaQuery.of(context).size.height / 2 - 340,
              child: _buildRipHint(),
            ),
        ],
      ),
    );
  }

  Widget _buildRipHint() {
    return Opacity(
      opacity: (1.0 - _ripProgress * 3).clamp(0.0, 1.0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.arrow_right_alt, color: AppTheme.secondary, size: 32),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black45,
                  border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
                ),
                child: const Text('RIP FROM LEFT TO RIGHT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.secondary, AppTheme.secondary.withOpacity(0)],
                stops: [_ripProgress, _ripProgress + 0.15],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealOverlay() {
    return AnimatedBuilder(
      animation: _revealFadeController,
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10 * _revealFadeController.value, sigmaY: 10 * _revealFadeController.value),
          child: Container(
            color: Colors.black.withOpacity(0.85 * _revealFadeController.value),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 620,
                  child: PageView.builder(
                    controller: _revealPageController,
                    itemCount: _revealedCards?.length ?? 0,
                    onPageChanged: (index) => setState(() => _currentRevealIndex = index),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final card = _revealedCards![index];
                      return AnimatedBuilder(
                        animation: _revealPageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_revealPageController.position.haveDimensions) {
                            value = _revealPageController.page! - index;
                            value = (1 - (value.abs() * 0.25)).clamp(0.0, 1.0);
                          }
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: value,
                              child: Center(
                                child: GachaCardWidget(
                                  card: card, 
                                  width: 320, 
                                  height: 500,
                                  isNew: context.read<GameState>().isCardNew(card.id),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 48),
                _buildRevealFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevealFooter() {
    final bool isLast = _currentRevealIndex == (_revealedCards?.length ?? 0) - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_revealedCards?.length ?? 0, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentRevealIndex == index ? 24 : 8,
                height: 4,
                decoration: BoxDecoration(
                  color: _currentRevealIndex == index ? AppTheme.secondary : Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: isLast ? _finish : () => _revealPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLast ? AppTheme.secondary : Colors.white12,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(isLast ? 'ADD TO COLLECTION' : 'NEXT CARD', 
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: isLast ? Colors.black : Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _revealPageController.dispose();
    _revealFadeController.dispose();
    _extractController.dispose();
    super.dispose();
  }
}
