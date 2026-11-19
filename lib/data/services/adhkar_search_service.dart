import 'package:productive_muslim/core/utils/arabic_text_normalizer.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';

/// Represents a matched Dhikr entry from an offline search with context.
class DhikrSearchResult {
  final DhikrItem item;
  final String matchedField;
  final String? snippet;

  const DhikrSearchResult({
    required this.item,
    required this.matchedField,
    this.snippet,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrSearchResult &&
          runtimeType == other.runtimeType &&
          item.id == other.item.id;

  @override
  int get hashCode => item.id.hashCode;
}

/// Represents a matched Dhikr collection (category) from an offline search with context.
class DhikrCollectionSearchResult {
  final DhikrCategory category;
  final String titleEn;
  final String titleAr;
  final int itemCount;
  final String matchedField;

  const DhikrCollectionSearchResult({
    required this.category,
    required this.titleEn,
    required this.titleAr,
    required this.itemCount,
    required this.matchedField,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrCollectionSearchResult &&
          runtimeType == other.runtimeType &&
          category == other.category;

  @override
  int get hashCode => category.hashCode;
}

/// Unified container holding matched collections and Dhikr items.
class AdhkarUnifiedSearchResult {
  final List<DhikrCollectionSearchResult> collections;
  final List<DhikrSearchResult> items;

  const AdhkarUnifiedSearchResult({
    this.collections = const [],
    this.items = const [],
  });

  bool get isEmpty => collections.isEmpty && items.isEmpty;
  bool get isNotEmpty => !isEmpty;
  int get totalCount => collections.length + items.length;
}

/// Metadata descriptor for searchable Adhkar collections.
class DhikrCollectionMetadata {
  final DhikrCategory category;
  final String titleEn;
  final String titleAr;
  final List<String> aliasesEn;
  final List<String> aliasesAr;

  const DhikrCollectionMetadata({
    required this.category,
    required this.titleEn,
    required this.titleAr,
    this.aliasesEn = const [],
    this.aliasesAr = const [],
  });

  static const List<DhikrCollectionMetadata> standardCollections = [
    DhikrCollectionMetadata(
      category: DhikrCategory.morning,
      titleEn: 'Morning Adhkar',
      titleAr: 'أذكار الصباح',
      aliasesEn: ['morning', 'morning adhkar', 'morning dhikr', 'dawn', 'fajr'],
      aliasesAr: ['الصباح', 'صباح', 'أذكار الصباح', 'اذكار الصباح'],
    ),
    DhikrCollectionMetadata(
      category: DhikrCategory.evening,
      titleEn: 'Evening Adhkar',
      titleAr: 'أذكار المساء',
      aliasesEn: [
        'evening',
        'evening adhkar',
        'evening dhikr',
        'dusk',
        'maghrib',
        'asr',
      ],
      aliasesAr: ['المساء', 'مساء', 'أذكار المساء', 'اذكار المساء'],
    ),
    DhikrCollectionMetadata(
      category: DhikrCategory.postPrayer,
      titleEn: 'Post-Salah Adhkar',
      titleAr: 'أذكار بعد الصلاة',
      aliasesEn: [
        'post-salah',
        'after salah',
        'post prayer',
        'after prayer',
        'salah',
        'prayer',
        'salah adhkar',
        'tasbih',
      ],
      aliasesAr: [
        'بعد الصلاة',
        'دبر الصلاة',
        'الصلاة',
        'أذكار بعد الصلاة',
        'اذكار بعد الصلاة',
        'تسبيح دبر الصلاة',
      ],
    ),
    DhikrCollectionMetadata(
      category: DhikrCategory.sleeping,
      titleEn: 'Bedtime Adhkar',
      titleAr: 'أذكار النوم',
      aliasesEn: ['bedtime', 'sleep', 'sleeping', 'before sleep', 'night'],
      aliasesAr: ['النوم', 'نوم', 'أذكار النوم', 'اذكار النوم', 'قبل النوم'],
    ),
    DhikrCollectionMetadata(
      category: DhikrCategory.wakingUp,
      titleEn: 'Waking Up Adhkar',
      titleAr: 'أذكار الاستيقاظ',
      aliasesEn: ['waking', 'waking up', 'upon waking', 'wake up', 'rise'],
      aliasesAr: [
        'الاستيقاظ',
        'استيقاظ',
        'أذكار الاستيقاظ',
        'اذكار الاستيقاظ',
        'عند الاستيقاظ',
      ],
    ),
    DhikrCollectionMetadata(
      category: DhikrCategory.general,
      titleEn: 'General Dhikr',
      titleAr: 'أذكار عامة',
      aliasesEn: ['general', 'general dhikr', 'general adhkar', 'daily dhikr'],
      aliasesAr: ['عامة', 'أذكار عامة', 'اذكار عامة', 'أذكار يومية'],
    ),
  ];
}

/// Fully offline search service for browsing and querying the reviewed Adhkar catalog.
class AdhkarSearchService {
  final AdhkarRepository _repository;

  AdhkarSearchService({required AdhkarRepository repository})
    : _repository = repository;

  /// Executes an offline search query against the reviewed catalog.
  ///
  /// Matches across:
  /// - Arabic sacred text (using diacritic-tolerant normalized matching)
  /// - English and Arabic titles
  /// - English and Arabic translations
  /// - Transliteration
  /// - Reference and multi-part sub-step contents
  ///
  /// Strictly respects [includePendingReview] to prevent unreviewed religious
  /// content from leaking into production searches.
  List<DhikrSearchResult> search({
    required String query,
    DhikrCategory? collection,
    DhikrSubject? subject,
    bool? includePendingReview,
  }) {
    final trimmed = query.trim();
    final qLower = trimmed.toLowerCase();

    // 1. Fetch available items gated by review status
    var items = _repository.getAll(includePendingReview: includePendingReview);

    // 2. Filter by collection if specified
    if (collection != null) {
      if (collection == DhikrCategory.morning) {
        items = items
            .where(
              (d) =>
                  d.category == DhikrCategory.morning ||
                  d.category == DhikrCategory.wakingUp,
            )
            .toList();
      } else {
        items = items.where((d) => d.category == collection).toList();
      }
    }

    // 3. Filter by subject if specified
    if (subject != null) {
      final info = DhikrSubjectInfo.getBySubject(subject);
      if (info != null) {
        items = items.where((d) => info.itemIds.contains(d.id)).toList();
      }
    }

    // 4. If query is empty, return all matching filtered items
    if (trimmed.isEmpty) {
      return items
          .map(
            (item) => DhikrSearchResult(
              item: item,
              matchedField: 'all',
              snippet: item.translationEn,
            ),
          )
          .toList();
    }

    // 5. Match query against multiple fields
    final results = <DhikrSearchResult>[];

    for (final item in items) {
      // Title match (highest relevance)
      if (item.titleEn.toLowerCase().contains(qLower)) {
        results.add(
          DhikrSearchResult(
            item: item,
            matchedField: 'titleEn',
            snippet: item.titleEn,
          ),
        );
        continue;
      }
      if (ArabicTextNormalizer.containsNormalized(item.titleAr, trimmed)) {
        results.add(
          DhikrSearchResult(
            item: item,
            matchedField: 'titleAr',
            snippet: item.titleAr,
          ),
        );
        continue;
      }

      // Arabic text match (diacritic-tolerant)
      if (ArabicTextNormalizer.containsNormalized(item.arabic, trimmed)) {
        results.add(
          DhikrSearchResult(
            item: item,
            matchedField: 'arabic',
            snippet: item.arabic,
          ),
        );
        continue;
      }

      // Translation match
      if (item.translationEn.toLowerCase().contains(qLower)) {
        results.add(
          DhikrSearchResult(
            item: item,
            matchedField: 'translationEn',
            snippet: item.translationEn,
          ),
        );
        continue;
      }
      if (ArabicTextNormalizer.containsNormalized(
        item.translationAr,
        trimmed,
      )) {
        results.add(
          DhikrSearchResult(
            item: item,
            matchedField: 'translationAr',
            snippet: item.translationAr,
          ),
        );
        continue;
      }

      // Transliteration match
      if (item.transliteration.toLowerCase().contains(qLower)) {
        results.add(
          DhikrSearchResult(
            item: item,
            matchedField: 'transliteration',
            snippet: item.transliteration,
          ),
        );
        continue;
      }

      // Reference match
      if (item.reference.toLowerCase().contains(qLower)) {
        results.add(
          DhikrSearchResult(
            item: item,
            matchedField: 'reference',
            snippet: item.reference,
          ),
        );
        continue;
      }

      // Multi-step sub-phrase match
      bool matchedInStep = false;
      for (final step in item.steps) {
        if (step.titleEn.toLowerCase().contains(qLower) ||
            step.translationEn.toLowerCase().contains(qLower) ||
            step.transliteration.toLowerCase().contains(qLower) ||
            ArabicTextNormalizer.containsNormalized(step.arabic, trimmed) ||
            ArabicTextNormalizer.containsNormalized(step.titleAr, trimmed)) {
          results.add(
            DhikrSearchResult(
              item: item,
              matchedField: 'step',
              snippet: '${step.titleEn}: ${step.translationEn}',
            ),
          );
          matchedInStep = true;
          break;
        }
      }
      if (matchedInStep) continue;
    }

    return results;
  }

  /// Searches essential collection titles and aliases offline.
  ///
  /// Returns matching collections with their approved item count.
  /// Strictly respects [includePendingReview] — collections with no approved
  /// items will never appear in production search results.
  List<DhikrCollectionSearchResult> searchCollections({
    required String query,
    bool? includePendingReview,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final qLower = trimmed.toLowerCase();
    final results = <DhikrCollectionSearchResult>[];

    for (final meta in DhikrCollectionMetadata.standardCollections) {
      final items = _repository.getByCategory(
        meta.category,
        includePendingReview: includePendingReview,
      );

      // If no items in this collection are approved/available, do not reveal it
      if (items.isEmpty) continue;

      String? matchedField;

      if (meta.titleEn.toLowerCase().contains(qLower) ||
          meta.aliasesEn.any(
            (a) =>
                a.toLowerCase().contains(qLower) ||
                qLower.contains(a.toLowerCase()),
          )) {
        matchedField = 'titleEn';
      } else if (ArabicTextNormalizer.containsNormalized(
            meta.titleAr,
            trimmed,
          ) ||
          meta.aliasesAr.any(
            (a) =>
                ArabicTextNormalizer.containsNormalized(a, trimmed) ||
                ArabicTextNormalizer.containsNormalized(trimmed, a),
          )) {
        matchedField = 'titleAr';
      }

      if (matchedField != null) {
        results.add(
          DhikrCollectionSearchResult(
            category: meta.category,
            titleEn: meta.titleEn,
            titleAr: meta.titleAr,
            itemCount: items.length,
            matchedField: matchedField,
          ),
        );
      }
    }

    return results;
  }

  /// Unified offline search across both collection titles and Dhikr items.
  ///
  /// Honors collection/subject filtering and review status boundaries.
  AdhkarUnifiedSearchResult unifiedSearch({
    required String query,
    DhikrCategory? collection,
    DhikrSubject? subject,
    bool? includePendingReview,
  }) {
    final matchedCollections = (subject != null || collection != null)
        ? const <DhikrCollectionSearchResult>[]
        : searchCollections(
            query: query,
            includePendingReview: includePendingReview,
          );

    final matchedItems = search(
      query: query,
      collection: collection,
      subject: subject,
      includePendingReview: includePendingReview,
    );

    return AdhkarUnifiedSearchResult(
      collections: matchedCollections,
      items: matchedItems,
    );
  }
}
