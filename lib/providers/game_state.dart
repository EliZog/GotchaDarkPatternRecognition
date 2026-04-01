import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/card_model.dart';

class GameState extends ChangeNotifier {
  int _energy = 30;
  int _packsAvailable = 10;
  int _packsOpenedTotal = 0;
  
  // Storage for duplicates
  final Map<String, GachaCard> _cardRegistry = {}; // id -> card object
  final Map<String, int> _cardCounts = {}; // id -> quantity
  final List<String> _collectionOrder = []; // To maintain original order in UI
  
  final Set<String> _unlockedDarkPatternIds = {};
  final Set<String> _newCardIds = {}; // Track which cards have a "NEW" badge
  Timer? _energyTimer;

  GameState() {
    _startEnergyTimer();
  }

  int get energy => _energy;
  int get packsAvailable => _packsAvailable;
  int get packsOpenedTotal => _packsOpenedTotal;
  
  List<GachaCard> get collection {
    return _collectionOrder.map((id) => _cardRegistry[id]!).toList();
  }

  int getCardCount(String id) => _cardCounts[id] ?? 0;

  int get goldenPackProgress => _packsOpenedTotal % 20;

  bool isCardNew(String id) => _newCardIds.contains(id);

  void markCardViewed(String id) {
    if (_newCardIds.remove(id)) {
      notifyListeners();
    }
  }

  void _startEnergyTimer() {
    _energyTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_energy < 30) {
        _energy++;
        notifyListeners();
      }
    });
  }

  bool spendEnergy(int amount) {
    if (_energy >= amount) {
      _energy -= amount;
      notifyListeners();
      return true;
    }
    return false;
  }

  void addPacks(int amount) {
    _packsAvailable = (_packsAvailable + amount).clamp(0, 10);
    notifyListeners();
  }

  void openPack(List<GachaCard> cards) {
    if (_packsAvailable > 0) {
      _packsAvailable--;
      _packsOpenedTotal++;
      
      for (var card in cards) {
        _addCardToInventory(card);
      }
      
      notifyListeners();
    }
  }

  bool _addCardToInventory(GachaCard card) {
    bool isFirstTime = false;
    if (!_cardCounts.containsKey(card.id)) {
      _cardCounts[card.id] = 1;
      _cardRegistry[card.id] = card;
      _collectionOrder.add(card.id);
      _newCardIds.add(card.id);
      isFirstTime = true;
    } else {
      _cardCounts[card.id] = (_cardCounts[card.id] ?? 0) + 1;
    }
    return isFirstTime;
  }

  bool unlockDarkPattern(String id, GachaCard card) {
    if (!_unlockedDarkPatternIds.contains(id)) {
      _unlockedDarkPatternIds.add(id);
      _addCardToInventory(card);
      notifyListeners();
      return true; // Unlocked successfully
    }
    return false; // Already unlocked
  }

  bool isDarkPatternUnlocked(String id) => _unlockedDarkPatternIds.contains(id);

  @override
  void dispose() {
    _energyTimer?.cancel();
    super.dispose();
  }
}
