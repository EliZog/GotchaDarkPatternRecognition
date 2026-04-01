import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../theme/app_theme.dart';
import 'gacha_card_widget.dart';

Future<void> showDiscoveryDialog(BuildContext context, GachaCard card) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Discovery',
    barrierColor: Colors.black.withOpacity(0.9),
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, anim1, anim2) {
      return Material(
        type: MaterialType.transparency,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'NEW ENTITY DETECTED',
                style: TextStyle(
                  color: AppTheme.primary, 
                  fontWeight: FontWeight.w900, 
                  fontSize: 16, 
                  letterSpacing: 4,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 32),
              ScaleTransition(
                scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
                child: RotationTransition(
                  turns: Tween<double>(begin: 0.1, end: 0).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
                  child: GachaCardWidget(card: card, width: 280, height: 420, isNew: true),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text('ACKNOWLEDGE'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
