import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state.dart';
import 'home_screen.dart';
import 'collection_screen.dart';
import 'shop_screen.dart';
import 'battle_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const ShopScreen(),
    const HomeScreen(),
    const CollectionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 24, top: 12),
        decoration: BoxDecoration(
          color: AppTheme.background.withOpacity(0.9),
          border: const Border(
            top: BorderSide(color: Color(0xFF201A61), width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.background.withOpacity(0.8),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.storefront_outlined, 'Shop'),
            _buildNavItem(1, Icons.style_outlined, 'Home'),
            _buildNavItem(2, Icons.auto_stories_outlined, 'Collection'),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
            onPressed: () {
              final gameState = context.read<GameState>();
            if (gameState.collection.length < 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You don\'t have enough cards to enter battle mode.'),
                  backgroundColor: AppTheme.error,
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BattleScreen()),
            );
          },
          backgroundColor: context.watch<GameState>().collection.length < 2 ? AppTheme.surfaceContainerHighest : AppTheme.secondary,
          foregroundColor: context.watch<GameState>().collection.length < 2 ? AppTheme.onSurfaceVariant : AppTheme.background,
          elevation: 8,
          shape: const CircleBorder(),
          child: const FaIcon(FontAwesomeIcons.skullCrossbones, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedScale(
        scale: isSelected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.secondary : const Color(0xFF454274),
              fill: isSelected ? 1.0 : 0.0,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.secondary : const Color(0xFF454274),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
