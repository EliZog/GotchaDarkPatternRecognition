import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/card_model.dart';
import '../theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GachaCardWidget extends StatefulWidget {
  final GachaCard card;
  final double width;
  final double height;
  final bool showStats;
  final bool isNew;
  final bool isMini;
  final VoidCallback? onInfoPressed;

  const GachaCardWidget({
    super.key,
    required this.card,
    this.width = 300,
    this.height = 460,
    this.showStats = true,
    this.isNew = false,
    this.isMini = false,
    this.onInfoPressed,
  });

  static Widget buildDarkPatternIcon(DarkPatternType? type, Color color, double size) {
    if (type == null) return Icon(Icons.psychology_alt, color: color, size: size);
    
    switch (type) {
      case DarkPatternType.comparisonPrevention: return Icon(Icons.balance, color: color, size: size);
      case DarkPatternType.confirmshaming: return Icon(Icons.pan_tool, color: color, size: size);
      case DarkPatternType.disguisedAds: return Icon(Icons.theater_comedy, color: color, size: size);
      case DarkPatternType.fakeScarcity: return Icon(Icons.inventory_2, color: color, size: size);
      case DarkPatternType.fakeSocialProof: return Icon(Icons.military_tech, color: color, size: size);
      case DarkPatternType.fakeUrgency: 
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Icon(Icons.bolt, color: color, size: size * 0.5),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Icon(Icons.timer, color: color, size: size * 0.8),
              ),
            ],
          ),
        );
      case DarkPatternType.forcedAction: 
        return SizedBox(
          width: size,
          height: size,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trip_origin, color: color, size: size * 0.45),
              SizedBox(
                width: size * 0.1,
                child: Divider(color: color, thickness: 2, height: 2),
              ),
              Icon(Icons.trip_origin, color: color, size: color == Colors.transparent ? 0 : size * 0.45),
            ],
          ),
        );
      case DarkPatternType.hardToCancel: return Icon(Icons.all_inclusive, color: color, size: size);
      case DarkPatternType.hiddenCosts: return Icon(Icons.attach_money, color: color, size: size);
      case DarkPatternType.hiddenSubscription: return Icon(Icons.visibility_off, color: color, size: size);
      case DarkPatternType.nagging: return Icon(Icons.record_voice_over, color: color, size: size);
      case DarkPatternType.obstruction: 
        return SizedBox(
          width: size,
          height: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   Container(width: size*0.4, height: size*0.2, color: color),
                   Container(width: size*0.4, height: size*0.2, color: color),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   Container(width: size*0.2, height: size*0.2, color: color),
                   Container(width: size*0.4, height: size*0.2, color: color),
                   Container(width: size*0.2, height: size*0.2, color: color),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   Container(width: size*0.4, height: size*0.2, color: color),
                   Container(width: size*0.4, height: size*0.2, color: color),
                ],
              ),
            ],
          ),
        );
      case DarkPatternType.preselection: return Icon(Icons.checklist, color: color, size: size);
      case DarkPatternType.sneaking: return FaIcon(FontAwesomeIcons.mask, color: color, size: size);
      case DarkPatternType.trickWording: return Icon(Icons.search, color: color, size: size);
      case DarkPatternType.visualInterference: return Icon(Icons.texture, color: color, size: size);
      case DarkPatternType.unknown: return Icon(Icons.psychology_alt, color: color, size: size);
    }
  }

  @override
  State<GachaCardWidget> createState() => _GachaCardWidgetState();
}

class _GachaCardWidgetState extends State<GachaCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _holoController;

  @override
  void initState() {
    super.initState();
    _holoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    final bool isHolo = widget.card.rarity == Rarity.rare || 
                        widget.card.rarity == Rarity.epic ||
                        widget.card.rarity == Rarity.legendary || 
                        widget.card.rarity == Rarity.mythic;
    final Color rarityColor = _getRarityColor(widget.card.rarity);
    final bool isMythic = widget.card.rarity == Rarity.mythic;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Invisible spacer to expand the gesture boundaries of the Stack
        Positioned(
          top: -24, left: -24,
          width: 48, height: 48,
          child: const SizedBox(),
        ),
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withOpacity(isMythic ? 0.8 : 0.4),
                blurRadius: 30,
                spreadRadius: isMythic ? 2 : -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Base Background forms the border
                if (isMythic)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _holoController,
                      builder: (context, child) => CustomPaint(
                        painter: StripePainter(
                          color1: rarityColor,
                          color2: Colors.black,
                          animationValue: _holoController.value,
                        ),
                      ),
                    ),
                  )
                else
                  Container(color: rarityColor),

                // Inner Main Area (shrinks inward by 4px to expose the border)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // Internal Content
                        Column(
                          children: [
                            // Header
                            if (!widget.isMini)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: rarityColor.withOpacity(0.15),
                                  border: Border(bottom: BorderSide(color: rarityColor.withOpacity(0.3), width: 1)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        GachaCardWidget.buildDarkPatternIcon(widget.card.darkPatternType, rarityColor, widget.width * 0.1),
                                      ],
                                    ),
                                    Text(
                                      widget.card.rarity.displayName.toUpperCase(),
                                      style: TextStyle(
                                        color: rarityColor, 
                                        fontWeight: FontWeight.w900, 
                                        letterSpacing: 2, 
                                        fontSize: widget.width * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Artwork Area
                            Expanded(
                              child: Center(
                                child: _buildCenterIcon(widget.card.id, widget.isMini ? widget.width * 0.5 : widget.width * 0.4, rarityColor),
                              ),
                            ),
                            
                            // Info Section
                            if (!widget.isMini)
                              Padding(
                                padding: EdgeInsets.all(widget.width * 0.06),
                                child: Column(
                                  children: [
                                    Text(
                                      widget.card.title.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: widget.width * 0.08, 
                                        fontWeight: FontWeight.w900, 
                                        height: 1,
                                        letterSpacing: -0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.visible,
                                    ),
                                    const SizedBox(height: 12),
                                    if (widget.showStats) ...[
                                      Text(
                                        widget.card.description,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _buildStatPill('ATK', widget.card.attack, rarityColor),
                                          const SizedBox(width: 12),
                                          _buildStatPill('DEF', widget.card.defense, rarityColor),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),

                        // Holographic Sheen
                        if (isHolo)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _holoController,
                              builder: (context, child) {
                                return IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.0),
                                          Colors.white.withOpacity(isMythic ? 0.15 : 0.08),
                                          Colors.white.withOpacity(0.0),
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                        transform: GradientRotation(_holoController.value * 2 * math.pi),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Top Left Info Button (Outside Card Bounds)
        if (widget.onInfoPressed != null)
          Positioned(
            top: -16,
            left: -16,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceContainerHighest,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.info_outline),
                color: Colors.white,
                iconSize: widget.width * 0.08,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: widget.onInfoPressed,
              ),
            ),
          ),
          
        // NEW Badge
        if (widget.isNew)
          Positioned(
            top: widget.onInfoPressed != null ? 36 : -12, // Push below info button if present
            left: -12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.error,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppTheme.error.withOpacity(0.4), blurRadius: 6),
                ],
              ),
              child: const Text('NEW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
            ),
          ),
      ],
    );
  }

  Widget _buildStatPill(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 8)),
          const SizedBox(width: 6),
          Text(value.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Color _getRarityColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.common: return AppTheme.rarityCommon;
      case Rarity.uncommon: return AppTheme.rarityUncommon;
      case Rarity.rare: return AppTheme.rarityRare;
      case Rarity.epic: return AppTheme.rarityEpic;
      case Rarity.legendary: return AppTheme.rarityLegendary;
      case Rarity.mythic: return AppTheme.rarityMythic;
    }
  }

  Widget _buildCenterIcon(String id, double size, Color color) {
    if (id == 'dp1') {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.calendar_today, color: color, size: size * 0.9),
            Positioned(
              top: size * 0.3, // Move higher up as requested
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.sync, color: color, size: size * 0.45), // Smaller arrows
                  Icon(Icons.attach_money, color: color, size: size * 0.25),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return Icon(
      _getIconForCardId(id), 
      color: color, 
      size: size,
    );
  }

  IconData _getIconForCardId(String id) {
    switch (id) {
      case 'dp1': return Icons.calendar_today;
      case 'dp2': return Icons.timer_off;
      case 'dp3': return Icons.bolt;
      case 'dp4': return Icons.play_circle_filled;
      case 'dp5': return Icons.share;
      case 'dp6': return Icons.style;
      case 'dp7': return Icons.mark_email_unread;
      case 'dp8': return Icons.monetization_on;
      case 'dp9': return Icons.account_circle;
      case 'dp10': return Icons.contrast;
      case 'dp11': return Icons.article;
      default: return Icons.psychology_alt;
    }
  }

  @override
  void dispose() {
    _holoController.dispose();
    super.dispose();
  }
}

class StripePainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double animationValue;

  StripePainter({required this.color1, required this.color2, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    paint.color = color2;
    const double stripeWidth = 20;
    const double gap = 20;
    
    // Shift creates the animated marching effect
    final double shift = animationValue * (stripeWidth + gap) * 2;

    for (double i = -size.height - (stripeWidth + gap) * 2; i < size.width; i += stripeWidth + gap) {
      final double x = i + shift;
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StripePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

