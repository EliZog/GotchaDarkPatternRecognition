import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/card_model.dart';
import 'dart:math' as math;

class CardDatabase {
  static List<GachaCard> allCards = [];
  
  static Future<void> loadCards() async {
    try {
      print("[CardDatabase] Loading cards from assets...");
      final String response = await rootBundle.loadString('assets/data/cards.json');
      final data = await json.decode(response);
      
      if (data is List) {
        allCards = data.map((e) => GachaCard.fromJson(e)).toList();
        print("[CardDatabase] Loaded ${allCards.length} cards.");
      } else {
        print("[CardDatabase] Error: Expected a JSON List but got ${data.runtimeType}");
      }
    } catch (e, stack) {
      print("[CardDatabase] FATAL ERROR loading cards: $e");
      print(stack);
    }
  }

  static List<GachaCard> generatePack({String packType = 'default'}) {
    final random = math.Random();
    
    if (allCards.isEmpty) {
      print("[CardDatabase] Warning: allCards is empty! Using placeholder card.");
      return List.generate(5, (index) => GachaCard(
        id: 'placeholder',
        title: 'Empty Pack Card',
        description: 'No card data found.',
        rarity: Rarity.common,
        type: CardType.creature,
        attack: 0,
        defense: 0,
        imageUrl: '',
      ));
    }

    return List.generate(5, (index) {
      final regularCards = allCards.where((c) => c.type != CardType.darkPattern).toList();
      final cardsToPickFrom = regularCards.isNotEmpty ? regularCards : allCards;
      
      return cardsToPickFrom[random.nextInt(cardsToPickFrom.length)];
    });
  }
}
