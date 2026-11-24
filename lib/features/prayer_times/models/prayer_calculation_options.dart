import 'package:adhan_dart/adhan_dart.dart';

/// Preset calculation methods supported by adhan_dart with human-readable labels.
class PrayerCalculationOptions {
  const PrayerCalculationOptions._();

  /// Curated list of calculation methods with major world standards listed first.
  static const List<CalculationMethod> availableMethods = [
    CalculationMethod.muslimWorldLeague,
    CalculationMethod.northAmerica,
    CalculationMethod.ummAlQura,
    CalculationMethod.egyptian,
    CalculationMethod.karachi,
    CalculationMethod.dubai,
    CalculationMethod.moonsightingCommittee,
    CalculationMethod.kuwait,
    CalculationMethod.qatar,
    CalculationMethod.singapore,
    CalculationMethod.turkiye,
    CalculationMethod.morocco,
    CalculationMethod.algerian,
    CalculationMethod.indonesian,
    CalculationMethod.tunisia,
    CalculationMethod.jordan,
    CalculationMethod.france,
    CalculationMethod.russia,
    CalculationMethod.portugal,
    CalculationMethod.gulfRegion,
    CalculationMethod.tehran,
    CalculationMethod.jafari,
  ];

  /// Available Asr madhab calculation options.
  static const List<Madhab> availableMadhabs = [Madhab.shafi, Madhab.hanafi];

  /// Builds calculation parameters from method preset and Asr madhab.
  static CalculationParameters buildParameters({
    required CalculationMethod method,
    required Madhab madhab,
  }) {
    final params = switch (method) {
      CalculationMethod.muslimWorldLeague =>
        CalculationMethodParameters.muslimWorldLeague(),
      CalculationMethod.egyptian => CalculationMethodParameters.egyptian(),
      CalculationMethod.karachi => CalculationMethodParameters.karachi(),
      CalculationMethod.ummAlQura => CalculationMethodParameters.ummAlQura(),
      CalculationMethod.dubai => CalculationMethodParameters.dubai(),
      CalculationMethod.moonsightingCommittee =>
        CalculationMethodParameters.moonsightingCommittee(),
      CalculationMethod.northAmerica =>
        CalculationMethodParameters.northAmerica(),
      CalculationMethod.kuwait => CalculationMethodParameters.kuwait(),
      CalculationMethod.qatar => CalculationMethodParameters.qatar(),
      CalculationMethod.singapore => CalculationMethodParameters.singapore(),
      CalculationMethod.tehran => CalculationMethodParameters.tehran(),
      CalculationMethod.turkiye => CalculationMethodParameters.turkiye(),
      CalculationMethod.morocco => CalculationMethodParameters.morocco(),
      CalculationMethod.algerian => CalculationMethodParameters.algerian(),
      CalculationMethod.indonesian => CalculationMethodParameters.indonesian(),
      CalculationMethod.jordan => CalculationMethodParameters.jordan(),
      CalculationMethod.tunisia => CalculationMethodParameters.tunisia(),
      CalculationMethod.france => CalculationMethodParameters.france(),
      CalculationMethod.russia => CalculationMethodParameters.russia(),
      CalculationMethod.portugal => CalculationMethodParameters.portugal(),
      CalculationMethod.gulfRegion => CalculationMethodParameters.gulfRegion(),
      CalculationMethod.jafari => CalculationMethodParameters.jafari(),
      CalculationMethod.other => CalculationMethodParameters.other(),
    };
    params.madhab = madhab;
    return params;
  }

  /// Full localized title for the calculation method.
  static String getMethodTitle(
    CalculationMethod method, {
    required bool isArabic,
  }) {
    if (isArabic) {
      return switch (method) {
        CalculationMethod.muslimWorldLeague => 'رابطة العالم الإسلامي (MWL)',
        CalculationMethod.northAmerica =>
          'الجمعية الإسلامية لأمريكا الشمالية (ISNA)',
        CalculationMethod.ummAlQura => 'جامعة أم القرى، مكة المكرمة',
        CalculationMethod.egyptian => 'الهيئة المصرية العامة للمساحة',
        CalculationMethod.karachi => 'جامعة العلوم الإسلامية، كراتشي',
        CalculationMethod.dubai => 'دبي، دولة الإمارات',
        CalculationMethod.moonsightingCommittee => 'لجنة رؤية الهلال',
        CalculationMethod.kuwait => 'وزارة الأوقاف، الكويت',
        CalculationMethod.qatar => 'وزارة الأوقاف، قطر',
        CalculationMethod.singapore => 'مجلس الشؤون الإسلامية، سنغافورة (MUIS)',
        CalculationMethod.turkiye => 'رئاسة الشؤون الدينية، تركيا (ديانت)',
        CalculationMethod.morocco => 'وزارة الأوقاف والشؤون الإسلامية، المغرب',
        CalculationMethod.algerian => 'وزارة الشؤون الدينية، الجزائر',
        CalculationMethod.indonesian =>
          'وزارة الشؤون الدينية، إندونيسيا (KEMENAG)',
        CalculationMethod.tunisia => 'وزارة الشؤون الدينية، تونس',
        CalculationMethod.jordan => 'وزارة الأوقاف، الأردن',
        CalculationMethod.france => 'اتحاد المنظمات الإسلامية في فرنسا (UOIF)',
        CalculationMethod.russia => 'الإدارة الدينية لمسلمي روسيا',
        CalculationMethod.portugal => 'الجالية الإسلامية في لشبونة، البرتغال',
        CalculationMethod.gulfRegion => 'منطقة الخليج العربي',
        CalculationMethod.tehran => 'معهد الجيوفيزياء، جامعة طهران',
        CalculationMethod.jafari => 'شيعة اثنا عشرية، معهد لواء، قم',
        CalculationMethod.other => 'مخصص',
      };
    }

    return switch (method) {
      CalculationMethod.muslimWorldLeague => 'Muslim World League (MWL)',
      CalculationMethod.northAmerica =>
        'Islamic Society of North America (ISNA)',
      CalculationMethod.ummAlQura => 'Umm al-Qura University, Makkah',
      CalculationMethod.egyptian => 'Egyptian General Authority of Survey',
      CalculationMethod.karachi => 'University of Islamic Sciences, Karachi',
      CalculationMethod.dubai => 'Dubai, UAE',
      CalculationMethod.moonsightingCommittee => 'Moonsighting Committee',
      CalculationMethod.kuwait => 'Kuwait',
      CalculationMethod.qatar => 'Qatar',
      CalculationMethod.singapore => 'Singapore (MUIS)',
      CalculationMethod.turkiye => 'Diyanet İşleri Başkanlığı, Turkey',
      CalculationMethod.morocco => 'Ministry of Endowments, Morocco',
      CalculationMethod.algerian => 'Ministry of Religious Affairs, Algeria',
      CalculationMethod.indonesian =>
        'Ministry of Religious Affairs, Indonesia',
      CalculationMethod.tunisia => 'Ministry of Religious Affairs, Tunisia',
      CalculationMethod.jordan => 'Ministry of Awqaf, Jordan',
      CalculationMethod.france =>
        'Union of Islamic Organizations of France (UOIF)',
      CalculationMethod.russia => 'Spiritual Administration of Muslims, Russia',
      CalculationMethod.portugal => 'Islamic Community of Lisbon, Portugal',
      CalculationMethod.gulfRegion => 'Gulf Region',
      CalculationMethod.tehran =>
        'Institute of Geophysics, University of Tehran',
      CalculationMethod.jafari => 'Shia Ithna-Ashari, Leva Institute, Qum',
      CalculationMethod.other => 'Custom',
    };
  }

  /// Short badge title suitable for header pills.
  static String getMethodShortName(
    CalculationMethod method, {
    required bool isArabic,
  }) {
    if (isArabic) {
      return switch (method) {
        CalculationMethod.muslimWorldLeague => 'رابطة العالم الإسلامي',
        CalculationMethod.northAmerica => 'أمريكا الشمالية (ISNA)',
        CalculationMethod.ummAlQura => 'أم القرى',
        CalculationMethod.egyptian => 'الهيئة المصرية',
        CalculationMethod.karachi => 'كراتشي',
        CalculationMethod.dubai => 'دبي',
        CalculationMethod.moonsightingCommittee => 'رؤية الهلال',
        CalculationMethod.kuwait => 'الكويت',
        CalculationMethod.qatar => 'قطر',
        CalculationMethod.singapore => 'سنغافورة (MUIS)',
        CalculationMethod.turkiye => 'تركيا (ديانت)',
        CalculationMethod.morocco => 'المغرب',
        CalculationMethod.algerian => 'الجزائر',
        CalculationMethod.indonesian => 'إندونيسيا',
        CalculationMethod.tunisia => 'تونس',
        CalculationMethod.jordan => 'الأردن',
        CalculationMethod.france => 'فرنسا (UOIF)',
        CalculationMethod.russia => 'روسيا',
        CalculationMethod.portugal => 'البرتغال',
        CalculationMethod.gulfRegion => 'الخليج',
        CalculationMethod.tehran => 'طهران',
        CalculationMethod.jafari => 'الجعفري',
        CalculationMethod.other => 'مخصص',
      };
    }

    return switch (method) {
      CalculationMethod.muslimWorldLeague => 'Muslim World League',
      CalculationMethod.northAmerica => 'ISNA (North America)',
      CalculationMethod.ummAlQura => 'Umm al-Qura',
      CalculationMethod.egyptian => 'Egyptian Authority',
      CalculationMethod.karachi => 'Karachi',
      CalculationMethod.dubai => 'Dubai',
      CalculationMethod.moonsightingCommittee => 'Moonsighting Committee',
      CalculationMethod.kuwait => 'Kuwait',
      CalculationMethod.qatar => 'Qatar',
      CalculationMethod.singapore => 'Singapore (MUIS)',
      CalculationMethod.turkiye => 'Turkey (Diyanet)',
      CalculationMethod.morocco => 'Morocco',
      CalculationMethod.algerian => 'Algeria',
      CalculationMethod.indonesian => 'Indonesia',
      CalculationMethod.tunisia => 'Tunisia',
      CalculationMethod.jordan => 'Jordan',
      CalculationMethod.france => 'France (UOIF)',
      CalculationMethod.russia => 'Russia',
      CalculationMethod.portugal => 'Portugal',
      CalculationMethod.gulfRegion => 'Gulf Region',
      CalculationMethod.tehran => 'Tehran',
      CalculationMethod.jafari => 'Jafari',
      CalculationMethod.other => 'Custom',
    };
  }

  /// Full localized title for the Asr madhab.
  static String getMadhabTitle(Madhab madhab, {required bool isArabic}) {
    if (isArabic) {
      return switch (madhab) {
        Madhab.shafi => 'الجمهور (الشافعي، المالكي، الحنبلي)',
        Madhab.hanafi => 'الحنفي (ظل مثلين)',
      };
    }

    return switch (madhab) {
      Madhab.shafi => 'Standard (Shafi\'i, Maliki, Hanbali)',
      Madhab.hanafi => 'Hanafi',
    };
  }

  /// Concise description of the shadow calculation for each madhab.
  static String getMadhabDescription(Madhab madhab, {required bool isArabic}) {
    if (isArabic) {
      return switch (madhab) {
        Madhab.shafi => 'يبدأ وقت العصر عندما يصير ظل كل شيء مثله (طول الظل 1)',
        Madhab.hanafi =>
          'يبدأ وقت العصر عندما يصير ظل كل شيء مثليه (طول الظل 2)',
      };
    }

    return switch (madhab) {
      Madhab.shafi =>
        'Asr begins when an object\'s shadow equals its height (factor 1)',
      Madhab.hanafi => 'Asr begins when an object\'s shadow equals twice its height (factor 2)',
    };
  }
}
