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

/// Discovered topics for exploratory browsing across the library.
///
/// NOTE: Categories/subjects are discovery aids only; they do not prescribe
/// specific times, occasions, or numerical targets.
enum DhikrSubject {
  gratitude,
  forgiveness,
  protection,
  sleepAndWaking,
  everyday,
}

class DhikrSubjectInfo {
  final DhikrSubject subject;
  final String key;
  final String titleEn;
  final String titleAr;
  final String descriptionEn;
  final String descriptionAr;
  final Set<String> itemIds;

  const DhikrSubjectInfo({
    required this.subject,
    required this.key,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.itemIds,
  });

  static const List<DhikrSubjectInfo> all = [
    DhikrSubjectInfo(
      subject: DhikrSubject.gratitude,
      key: 'gratitude',
      titleEn: 'Gratitude & Praise',
      titleAr: 'الحمد والثناء',
      descriptionEn: 'Praises and glorifications of Allah',
      descriptionAr: 'تسبيح الله وحمده والثناء عليه',
      itemIds: {
        'wake_up_1',
        'subhanallahi_wa_bihamdihi_100',
        'sleep_33_tasbih',
        'post_salah_tasbih',
        'general_subhanallah_bihamdihi',
        'general_four_beloved_words',
      },
    ),
    DhikrSubjectInfo(
      subject: DhikrSubject.forgiveness,
      key: 'forgiveness',
      titleEn: 'Forgiveness & Repentance',
      titleAr: 'الاستغفار والتوبة',
      descriptionEn: 'Seeking pardon and turning back to Allah',
      descriptionAr: 'طلب المغفرة والإنابة إلى الله',
      itemIds: {
        'sayyid_al_istighfar',
        'post_salah_astaghfirullah',
        'general_istighfar',
      },
    ),
    DhikrSubjectInfo(
      subject: DhikrSubject.protection,
      key: 'protection',
      titleEn: 'Protection & Refuge',
      titleAr: 'الحفظ والاستعاذة',
      descriptionEn: 'Seeking safety and refuge in Allah',
      descriptionAr: 'التحصين وطلب الحفظ والعصمة من الشرور',
      itemIds: {
        'ayat_al_kursi',
        'bismillah_alladhi_morning',
        'raditu_billahi_morning',
        'bismillah_alladhi_evening',
        'audhu_bikalimatillah',
        'sleep_ayat_kursi',
      },
    ),
    DhikrSubjectInfo(
      subject: DhikrSubject.sleepAndWaking,
      key: 'sleep_waking',
      titleEn: 'Sleep & Waking',
      titleAr: 'النوم والاستيقاظ',
      descriptionEn: 'Remembrances upon waking and resting',
      descriptionAr: 'أذكار وأدعية النوم واليقظة',
      itemIds: {
        'wake_up_1',
        'wake_up_2',
        'sleep_bismika_allahumma',
        'sleep_33_tasbih',
        'sleep_ayat_kursi',
      },
    ),
    DhikrSubjectInfo(
      subject: DhikrSubject.everyday,
      key: 'everyday',
      titleEn: 'Everyday Situations',
      titleAr: 'المعاملات واليوم',
      descriptionEn: 'Daily routines, knowledge, and movements',
      descriptionAr: 'الخروج والدخول وطلب العلم وحاجات اليوم',
      itemIds: {
        'leaving_home',
        'entering_home',
        'dua_knowledge_focus',
        'raditu_billahi_morning',
        'general_la_hawla',
        'general_salawat',
      },
    ),
  ];

  static DhikrSubjectInfo? getBySubject(DhikrSubject subject) {
    return all.where((s) => s.subject == subject).firstOrNull;
  }

  static DhikrSubjectInfo? getByKey(String key) {
    return all.where((s) => s.key == key).firstOrNull;
  }

  static List<DhikrSubject> getSubjectsForItem(String itemId) {
    return all
        .where((s) => s.itemIds.contains(itemId))
        .map((s) => s.subject)
        .toList();
  }
}
