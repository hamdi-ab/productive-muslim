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
}
