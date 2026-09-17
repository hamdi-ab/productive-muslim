class BarakahPrompt {
  const BarakahPrompt._(this.id, this.sourceIds);

  final String id;
  final List<String> sourceIds;

  static const List<BarakahPrompt> all = [
    BarakahPrompt._('good_intentions_v1', ['good_intentions']),
    BarakahPrompt._('piety_v1', ['piety']),
    BarakahPrompt._('trust_in_allah_v1', ['trust_in_allah']),
    BarakahPrompt._('quran_v1', ['quran']),
    BarakahPrompt._('bismillah_v1', ['bismillah']),
    BarakahPrompt._('eating_together_v1', ['eating_together']),
    BarakahPrompt._('honesty_in_trade_v1', ['honesty_in_trade']),
    BarakahPrompt._('dua_v1', ['dua']),
    BarakahPrompt._('halal_income_v1', ['halal_income']),
    BarakahPrompt._('sunnah_v1', ['sunnah']),
    BarakahPrompt._('istikhara_v1', ['istikhara']),
    BarakahPrompt._('gratitude_v1', ['gratitude']),
    BarakahPrompt._('charity_v1', ['charity']),
    BarakahPrompt._('kinship_v1', ['kinship']),
    BarakahPrompt._('early_rising_v1', ['early_rising']),
    BarakahPrompt._('marriage_v1', ['marriage']),
    BarakahPrompt._('salah_v1', ['salah']),
    BarakahPrompt._('forgiveness_v1', ['forgiveness']),
  ];

  static BarakahPrompt forDate(String date) {
    if (date.length != 10 || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      throw ArgumentError.value(date, 'date', 'Expected YYYY-MM-DD');
    }
    final year = int.parse(date.substring(0, 4));
    final month = int.parse(date.substring(5, 7));
    final day = int.parse(date.substring(8, 10));
    final utcDate = DateTime.utc(year, month, day);
    if (utcDate.year != year || utcDate.month != month || utcDate.day != day) {
      throw ArgumentError.value(date, 'date', 'Invalid calendar date');
    }
    final ordinal = utcDate.difference(DateTime.utc(1970)).inDays;
    return all[ordinal % all.length];
  }
}
