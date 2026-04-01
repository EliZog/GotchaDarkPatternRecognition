import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class BoosterPackWidget extends StatefulWidget {
  final String imageUrl;
  final String seriesName;
  final Color accentColor;
  final String? heroTag;
  final double ripProgress;
  final bool hasDropShadow;

  const BoosterPackWidget({
    super.key,
    required this.imageUrl,
    required this.seriesName,
    required this.accentColor,
    this.heroTag,
    this.ripProgress = 0.0,
    this.hasDropShadow = true,
  });

  @override
  State<BoosterPackWidget> createState() => _BoosterPackWidgetState();
}

class _BoosterPackWidgetState extends State<BoosterPackWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Subtle floating movement (skip if ripping for stability)
        final tilt = widget.ripProgress > 0 ? 0.0 : math.sin(_controller.value * 2 * math.pi) * 0.02;
        final float = widget.ripProgress > 0 ? 0.0 : math.cos(_controller.value * 2 * math.pi) * 10;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(tilt)
            ..rotateX(tilt * 0.5)
            ..translate(0.0, float, 0.0),
          alignment: Alignment.center,
          child: Container(
            width: 280,
            height: 440,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: widget.hasDropShadow ? [
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ] : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // PACK BODY (Rest of the pack)
                Positioned(
                  top: 60, // Start below the "lid" line
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildPackMainContent(isLid: false),
                ),

                // PACK LID (The top part that rips off)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 60, // The height of the lid
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..translate(300 * widget.ripProgress, -150 * widget.ripProgress, 100 * widget.ripProgress)
                      ..rotateZ(0.8 * widget.ripProgress)
                      ..rotateX(-0.5 * widget.ripProgress),
                    alignment: Alignment.topLeft,
                    child: _buildPackMainContent(isLid: true),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackMainContent({required bool isLid}) {
    return Container(
      width: 280, // Explicitly set width
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHighest,
        borderRadius: isLid 
          ? const BorderRadius.vertical(top: Radius.circular(24))
          : const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Base / Image
          Positioned(
            top: isLid ? 0 : -60,
            left: 0,
            right: 0,
            height: 440,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackDesign(),
            ),
          ),

          // Gloss Overlay
          Positioned(
            top: isLid ? 0 : -60,
            left: 0,
            right: 0,
            height: 440,
            child: _buildGlossEffect(),
          ),

          // Jagged Edge
          if (isLid)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildJaggedEdge(isTop: true))
          else
            Positioned(top: 0, left: 0, right: 0, child: _buildJaggedEdge(isTop: false)),

          // Details - Span full width
          if (!isLid) 
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: _buildPackDetails(),
            ),
          
          // Outer Crimp
          if (isLid)
            Positioned(top: 0, left: 0, right: 0, child: _buildCrimp())
          else
            Positioned(bottom: 0, left: 0, right: 0, child: _buildCrimp()),
        ],
      ),
    );
  }

  Widget _buildJaggedEdge({required bool isTop}) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
      ),
      child: Row(
        children: List.generate(24, (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: isTop 
                ? const BorderRadius.vertical(top: Radius.circular(2))
                : const BorderRadius.vertical(bottom: Radius.circular(2)),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildFallbackDesign() {
    if (widget.seriesName.contains('Instagram')) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFf9ce34), Color(0xFFee2a7b), Color(0xFF6228d7)],
          ),
        ),
        child: Center(
          child: FaIcon(FontAwesomeIcons.instagram, size: 80, color: Colors.white.withOpacity(0.5)),
        ),
      );
    }
    
    if (widget.seriesName.contains('Candy Crush')) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.pinkAccent.shade100, Colors.pink, Colors.purpleAccent],
          ),
        ),
        child: Center(
          child: FaIcon(FontAwesomeIcons.candyCane, size: 80, color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor.withOpacity(0.3),
            AppTheme.surfaceContainerLow,
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildGlossEffect() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.transparent,
            Colors.white.withOpacity(0.05),
            Colors.transparent,
            Colors.white.withOpacity(0.08),
          ],
          stops: const [0.0, 0.45, 0.5, 0.55, 1.0],
          transform: GradientRotation(_controller.value * 2 * math.pi),
        ),
      ),
    );
  }

  Widget _buildCrimp() {
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/carbon-fibre.png'),
          repeat: ImageRepeat.repeat,
          opacity: 0.05,
        ),
      ),
    );
  }

  Widget _buildPackDetails() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          stops: const [0.4, 0.9],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.accentColor.withOpacity(0.4)),
            ),
            child: const Text('BOOSTER PACK', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
          const SizedBox(height: 12),
          Text(
            widget.seriesName.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.0),
          ),
          const SizedBox(height: 8),
          Container(height: 2, width: 40, decoration: BoxDecoration(color: widget.accentColor, boxShadow: [BoxShadow(color: widget.accentColor, blurRadius: 10)])),
          const SizedBox(height: 8),
          const Text('5 CARDS • ELITE SERIES', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
