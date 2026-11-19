enum DhikrCategory {
  morning,
  evening,
  wakingUp,
  sleeping,
  postPrayer,
  dailySunnah,
  general,
}

enum ContentReviewStatus { approved, pendingReview }

class DhikrStep {
  final String id;
  final String titleEn;
  final String titleAr;
  final String arabic;
  final String transliteration;
  final String translationEn;
  final String translationAr;
  final int targetCount;

  const DhikrStep({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.arabic,
    required this.transliteration,
    required this.translationEn,
    required this.translationAr,
    required this.targetCount,
  });
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
  final ContentReviewStatus reviewStatus;
  final bool isCountPrescribed;
  final List<DhikrStep> steps;

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
    this.reviewStatus = ContentReviewStatus.pendingReview,
    this.isCountPrescribed = false,
    this.steps = const [],
  });

  bool get isApproved => reviewStatus == ContentReviewStatus.approved;
  bool get isPendingReview => reviewStatus == ContentReviewStatus.pendingReview;
  bool get hasSteps => steps.isNotEmpty;

  /// Returns the 0-based index of the active step for the given progress count.
  int currentStepIndex(int count) {
    if (!hasSteps) return 0;
    int accumulated = 0;
    for (int i = 0; i < steps.length; i++) {
      accumulated += steps[i].targetCount;
      if (count < accumulated) {
        return i;
      }
    }
    return steps.length - 1;
  }

  /// Returns the current active step, or null if no steps defined.
  DhikrStep? currentStep(int count) {
    if (!hasSteps) return null;
    return steps[currentStepIndex(count)];
  }

  /// Returns the progress within the active step (0 up to step.targetCount).
  int currentStepProgress(int count) {
    if (!hasSteps) return count;
    int accumulated = 0;
    for (final step in steps) {
      if (count < accumulated + step.targetCount) {
        return count - accumulated;
      }
      accumulated += step.targetCount;
    }
    return steps.last.targetCount;
  }
}
