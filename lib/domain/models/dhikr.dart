enum DhikrCategory {
  morning,
  evening,
  wakingUp,
  sleeping,
  postPrayer,
  dailySunnah,
  general,
}

class DhikrItem {
  final String id;
  final DhikrCategory category;
  final String titleEn;
  final String titleAr;
  final String arabic;
  final String transliteration;
  final String translationEn;
  final String translationAr;
  final String reference;
  final String virtue;
  final int targetCount;
  final int order;
  final int contentVersion;

  const DhikrItem({
    required this.id,
    required this.category,
    required this.titleEn,
    required this.titleAr,
    required this.arabic,
    required this.transliteration,
    required this.translationEn,
    required this.translationAr,
    required this.reference,
    required this.virtue,
    this.targetCount = 1,
    this.order = 0,
    this.contentVersion = 1,
  });
}
