import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/game_state.dart';
import 'screens/main_layout.dart';
import 'data/card_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CardDatabase.loadCards();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const GotchaApp(),
    ),
  );
}

class GotchaApp extends StatelessWidget {
  const GotchaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gotcha! Dark Patterns',
      theme: AppTheme.darkTheme,
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
