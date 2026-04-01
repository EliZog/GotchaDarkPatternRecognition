enum Rarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
  mythic,
}

extension RarityExtension on Rarity {
  String get displayName {
    switch (this) {
      case Rarity.common: return 'common';
      case Rarity.uncommon: return 'uncommon';
      case Rarity.rare: return 'rare';
      case Rarity.epic: return 'epic';
      case Rarity.legendary: return 'legendary';
      case Rarity.mythic: return 'mythic';
    }
  }
}

enum CardType {
  creature,
  spell,
  darkPattern,
}

extension CardTypeExtension on CardType {
  String get displayName {
    switch (this) {
      case CardType.creature: return 'creature';
      case CardType.spell: return 'spell';
      case CardType.darkPattern: return 'darkPattern';
    }
  }
}

enum DarkPatternType {
  comparisonPrevention,
  confirmshaming,
  disguisedAds,
  fakeScarcity,
  fakeSocialProof,
  fakeUrgency,
  forcedAction,
  hardToCancel,
  hiddenCosts,
  hiddenSubscription,
  nagging,
  obstruction,
  preselection,
  sneaking,
  trickWording,
  visualInterference,
  unknown,
}

extension DarkPatternTypeExtension on DarkPatternType {
  String get displayName {
    switch (this) {
      case DarkPatternType.comparisonPrevention: return 'Comparison Prevention';
      case DarkPatternType.confirmshaming:
        return 'Confirm Shaming';
      case DarkPatternType.disguisedAds: return 'Disguised Ads';
      case DarkPatternType.fakeScarcity: return 'Fake Scarcity';
      case DarkPatternType.fakeSocialProof: return 'Fake Social Proof';
      case DarkPatternType.fakeUrgency: return 'Fake Urgency';
      case DarkPatternType.forcedAction: return 'Forced Action';
      case DarkPatternType.hardToCancel: return 'Hard To Cancel';
      case DarkPatternType.hiddenCosts: return 'Hidden Costs';
      case DarkPatternType.hiddenSubscription: return 'Hidden Subscription';
      case DarkPatternType.nagging: return 'Nagging';
      case DarkPatternType.obstruction: return 'Obstruction';
      case DarkPatternType.preselection: return 'Preselection';
      case DarkPatternType.sneaking: return 'Sneaking';
      case DarkPatternType.trickWording: return 'Trick Wording';
      case DarkPatternType.visualInterference: return 'Visual Interference';
      case DarkPatternType.unknown: return 'To be determined';
    }
  }
}

class GachaCard {
  final String id;
  final String title;
  final String description;
  final Rarity rarity;
  final CardType type;
  final DarkPatternType? darkPatternType;
  final int attack;
  final int defense;
  final String? whyItWorks;
  final String? solution;
  final String imageUrl;

  GachaCard({
    required this.id,
    required this.title,
    required this.description,
    required this.rarity,
    required this.type,
    this.darkPatternType,
    required this.attack,
    required this.defense,
    this.whyItWorks,
    this.solution,
    required this.imageUrl,
  });

  factory GachaCard.fromJson(Map<String, dynamic> json) {
    Rarity parseRarity(String? val) {
      return Rarity.values.firstWhere(
        (e) => e.toString().split('.').last == val,
        orElse: () => Rarity.common,
      );
    }

    CardType parseType(String? val) {
      return CardType.values.firstWhere(
        (e) => e.toString().split('.').last == val,
        orElse: () => CardType.creature,
      );
    }

    DarkPatternType? parseDarkPatternType(String? val) {
      if (val == null) return null;
      return DarkPatternType.values.firstWhere(
        (e) => e.toString().split('.').last == val,
        orElse: () => DarkPatternType.trickWording,
      );
    }

    // Handle TBD defaults for missing data
    const String tbd = 'To be determined';

    return GachaCard(
      id: json['id'] ?? 'unknown',
      title: json['title'] ?? tbd,
      description: json['description'] ?? tbd,
      rarity: parseRarity(json['rarity']),
      type: parseType(json['type']),
      darkPatternType: parseDarkPatternType(json['darkPatternType']) ?? (json['type'] == 'darkPattern' ? DarkPatternType.unknown : null),
      attack: json['attack'] ?? 0,
      defense: json['defense'] ?? 0,
      whyItWorks: json['whyItWorks'] ?? tbd,
      solution: json['solution'] ?? tbd,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  bool get isDarkPattern => type == CardType.darkPattern;
}
